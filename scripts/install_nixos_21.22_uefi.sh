#!/usr/bin/env bash
#this script should be executed with a URL to an authorized_keys file as the first parameter
parted /dev/$1 -- mklabel gpt
parted /dev/$1 -- mkpart primary 512MiB -8GiB
parted /dev/$1 -- mkpart primary linux-swap -8GiB 100%
parted /dev/$1 -- mkpart ESP fat32 1MiB 512MiB
parted /dev/$1 -- set 3 esp on

mkfs.ext4 -L nixos /dev/$11 
mkswap -L swap /dev/$12 
mkfs.fat -F 32 -n boot /dev/$13

mount /dev/$11 /mnt 
mkdir -p /mnt/boot
mount /dev/$13 /mnt/boot
swapon /dev/$12 

nixos-generate-config --root /mnt 

#remove closing } in the default nix configuration
sed -i 'x;${s/}$//;p;x;};1d' /mnt/etc/nixos/configuration.nix

#append our config
cat >> /mnt/etc/nixos/configuration.nix <<EOF
  boot.loader.grub.device = "/dev/$1";
  
  users.mutableUsers = false;

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "yes";
    ports = [ 4096 ];
  };

  users.users.root.openssh.authorizedKeys.keys = [
    $(curl $2 | xargs -I '{}' echo \"{}\" | tr '\n' ' ' | sed 's/ \{1,\}/ /g')
  ];

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 4096 ];
}
EOF

nixos-install --no-root-passwd