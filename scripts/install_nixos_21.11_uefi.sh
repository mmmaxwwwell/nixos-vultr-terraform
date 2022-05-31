#!/usr/bin/env bash
i=1
for var in "$@"
do
  if [[ "$var" != *"--"* ]]; then
    case "$i" in
    1)
      TARGET_DEVICE=$var
      ;;
    2)
      AUTHORIZED_KEYS=$var
      ;;
    esac
    ((i=i+1))
  fi
done

TARGET_DEVICE="${TARGET_DEVICE:-sda}"
AUTHORIZED_KEYS="${AUTHORIZED_KEYS:-\"$(curl https://mmmaxwwwell.keybase.pub/keys/phoebe 2>/dev/null)\" \"$(curl https://mmmaxwwwell.keybase.pub/keys/eros 2>/dev/null)\"}"

echo "TARGET_DEVICE:$TARGET_DEVICE"
echo "AUTHORIZED_KEYS:$AUTHORIZED_KEYS"

if [[ "$0 $*" =~ .*"--skip-confirm".* ]]; then
  echo "skipping erasure confirmation due to --skip-confirm flag"
else
  echo "This will erase all data on /dev/$TARGET_DEVICE"
  read -p "Press Y to continue or any other key to cancel:" -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "user confirmed erasure"
  else
    echo "user canceled"
    exit
  fi
fi

ls /dev/${TARGET_DEVICE}?* | xargs -n1 umount -l
wipefs --all --force /dev/$TARGET_DEVICE
partprobe /dev/${TARGET_DEVICE}

parted /dev/$TARGET_DEVICE -- mklabel gpt
parted -a optimal /dev/$TARGET_DEVICE -- mkpart primary 512MiB -8GiB
parted -a optimal /dev/$TARGET_DEVICE -- mkpart primary linux-swap -8GiB 100%
parted -a optimal /dev/$TARGET_DEVICE -- mkpart ESP fat32 1MiB 512MiB
parted /dev/$TARGET_DEVICE -- set 3 esp on

mkfs.ext4 -F -L nixos /dev/${TARGET_DEVICE}1 
mkswap -L swap /dev/${TARGET_DEVICE}2 
mkfs.fat -F 32 -n boot /dev/${TARGET_DEVICE}3

mount /dev/${TARGET_DEVICE}1 /mnt 
mkdir -p /mnt/boot
mount /dev/${TARGET_DEVICE}3 /mnt/boot
swapon /dev/${TARGET_DEVICE}2 

nixos-generate-config --root /mnt 

#remove closing } in the default nix configuration
sed -i 'x;${s/}$//;p;x;};1d' /mnt/etc/nixos/configuration.nix

#append our config
cat >> /mnt/etc/nixos/configuration.nix <<EOF
  boot.loader.grub.device = "/dev/$TARGET_DEVICE";
  
  users.mutableUsers = false;

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "yes";
    ports = [ 4096 ];
  };

  users.users.root.openssh.authorizedKeys.keys = [
    $AUTHORIZED_KEYS
  ];

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 4096 ];
}
EOF

nixos-install --no-root-passwd