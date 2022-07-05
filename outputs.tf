output beacon_public_ip { 
    value = vultr_instance.beacon_1.main_ip
}

output root_domain { 
    value = var.root_domain
}