# https://github.com/go-gandi/terraform-provider-gandi

data "gandi_domain" "root_domain" {
  name = var.root_domain
}

data "gandi_livedns_domain" "root_domain" {
  name = var.root_domain
}

resource "gandi_livedns_record" "hostname" {
  zone = "${data.gandi_livedns_domain.root_domain.id}"
  name = "${var.hostname}"
  type = "A"
  ttl = 300
  
  values = [
    "${vultr_instance.beacon_1.main_ip}"
  ]

  depends_on = [
    vultr_instance.beacon_1
  ]
}

resource "gandi_livedns_record" "root" {
  zone = "${data.gandi_livedns_domain.root_domain.id}"
  name = "@"
  type = "A"
  ttl = 300
  
  values = [
    "${vultr_instance.beacon_1.main_ip}"
  ]

  depends_on = [
    vultr_instance.beacon_1,
    data.gandi_livedns_domain.root_domain
  ]
}

resource "gandi_livedns_record" "www_cname" {
  zone = "${data.gandi_livedns_domain.root_domain.id}"
  name = "*"
  type = "CNAME"
  ttl = 3600
  
  values = [
    "${var.root_domain}."
  ]

  depends_on = [
    vultr_instance.beacon_1,
    data.gandi_livedns_domain.root_domain,
  ]
}