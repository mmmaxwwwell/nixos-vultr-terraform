#!/usr/bin/env bash
#this script should be executed with a URL to an authorized_keys file as the first parameter
parted /dev/${storage_device_prefix} -- mklabel msdos 
parted /dev/${storage_device_prefix} -- mkpart primary 1MiB -8GiB 
parted /dev/${storage_device_prefix} -- mkpart primary linux-swap -8GiB 100% 

mkfs.ext4 -L nixos /dev/${storage_device_prefix}1 
mkswap -L swap /dev/${storage_device_prefix}2 

mount /dev/${storage_device_prefix}1 /mnt 
swapon /dev/${storage_device_prefix}2 

nixos-generate-config --root /mnt 

#remove closing } in the default nix configuration
sed -i 'x;$${s/}$//;p;x;};1d' /mnt/etc/nixos/configuration.nix

#append our config
cat >> /mnt/etc/nixos/configuration.nix <<EOF


  boot.loader.grub.device = "/dev/${storage_device_prefix}";
  
  users.mutableUsers = false;

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "yes";
    ports = [ ${ssh_port} ];
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "${ssh_authorized_key}"
  ];

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ ${ssh_port} ];
  networking.hostName = "${hostname}";
}
EOF

nixos-install --no-root-passwd