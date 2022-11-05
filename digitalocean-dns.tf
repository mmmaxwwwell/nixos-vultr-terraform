# resource "digitalocean_domain" "default" {
#   name = "${var.root_domain}"
# }

resource "digitalocean_record" "root" {
  domain = digitalocean_domain.default.id
  type   = "A"
  name   = "@"
  value  = "${vultr_instance.beacon_1.main_ip}"
  depends_on = [
    vultr_instance.beacon_1,
  ]
}

resource "digitalocean_record" "wildcard" {
  domain = digitalocean_domain.default.id
  type   = "CNAME"
  name   = "*"
  value  = "${var.root_domain}"
  depends_on = [
    vultr_instance.beacon_1,
    digitalocean_record.root
  ]
}

