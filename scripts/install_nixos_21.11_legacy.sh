#!/usr/bin/env bash
#this script should be executed with a URL to an authorized_keys file as the first parameter
parted /dev/vda -- mklabel msdos 
parted /dev/vda -- mkpart primary 1MiB -8GiB 
parted /dev/vda -- mkpart primary linux-swap -8GiB 100% 

mkfs.ext4 -L nixos /dev/vda1 
mkswap -L swap /dev/vda2 

mount /dev/vda1 /mnt 
swapon /dev/vda2 

nixos-generate-config --root /mnt 

#remove closing } in the default nix configuration
sed -i 'x;${s/}$//;p;x;};1d' /mnt/etc/nixos/configuration.nix

#append our config
cat >> /mnt/etc/nixos/configuration.nix <<EOF
  boot.loader.grub.device = "/dev/vda";
  
  users.mutableUsers = false;

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "yes";
    ports = [ 4096 ];
  };

  users.users.root.openssh.authorizedKeys.keys = [
    $(curl $1 | xargs -I '{}' echo \"{}\" | tr '\n' ' ' | sed 's/ \{1,\}/ /g')
  ];

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 4096 ];
}
EOF

nixos-install --no-root-passwd