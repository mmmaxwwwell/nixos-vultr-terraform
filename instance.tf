resource "vultr_instance" "beacon_1" {
  plan = "${var.vultr_instance_plan}"
  region = "${var.vultr_instance_region}"
  iso_id = "${var.nixos_iso_vultr_id}"
  label = "${var.stack_name}-${var.env}-${var.hostname}"
  hostname = "${var.hostname}"
  enable_ipv6 = true
  ddos_protection = var.ddos_protection
  activation_email = false

  connection {
    type = "ssh"
    user = "root"
    host = vultr_instance.beacon_1.main_ip
    port = 22
    agent = true
  }

  provisioner "file" {
    content = data.template_file.init.rendered
    destination = "/tmp/install_nixos_21_11.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install_nixos_21_11.sh",
      "/tmp/install_nixos_21_11.sh | tee -a /var/log/install_nixos_21_11.sh.log",
    ]
  }

  # this removes the custom nixOS iso after installing the system
  provisioner "local-exec" {
    command = "wget \"https://api.vultr.com/v2/instances/${vultr_instance.beacon_1.id}/iso/detach\" --post-data=\"\" --header \"Authorization: Bearer ${var.vultr_api_key}\" -O /dev/null"
  }  
}

data "template_file" "init" {
  template = "${file("${path.module}/scripts/install_nixos_21.11_legacy.sh.tpl")}"
  vars = {
    hostname = "${var.hostname}"
    storage_device_prefix = "${var.storage_device_prefix}"
    ssh_port = "${var.ssh_port}"
    ssh_authorized_key = var.ssh_authorized_key
  }
}

output install_script { 
  value = data.template_file.init.rendered
}