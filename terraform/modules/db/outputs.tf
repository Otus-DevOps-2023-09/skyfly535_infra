output "external_ip_address_db" {
  value = [for ip in yandex_compute_instance.db.*.network_interface.0.nat_ip_address : ip]
}
output "internal_ip_address_db" {
  value = [for ip in yandex_compute_instance.db.*.network_interface.0.ip_address : ip]
}
