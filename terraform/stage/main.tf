# terraform {
#   required_providers {
#     yandex = {
#       source = "yandex-cloud/yandex"
#     }
#   }
#   required_version = ">= 0.13"

# }
provider "yandex" {
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}

module "app" {
  source              = "/home/roman/DevOps/skyfly535_infra/terraform/modules/app"
  public_key_path     = var.public_key_path
  private_key_path    = var.private_key_path
  app_disk_image      = var.app_disk_image
  subnet_id           = var.subnet_id
  instances_app_count = 1
  db_ip               = module.db.internal_ip_address_db.0
}

module "db" {
  source              = "/home/roman/DevOps/skyfly535_infra/terraform/modules/db"
  public_key_path     = var.public_key_path
  private_key_path    = var.private_key_path
  db_disk_image       = var.db_disk_image
  subnet_id           = var.subnet_id
  instances_db_count = 1
}