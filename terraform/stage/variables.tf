variable "cloud_id" {
  description = "Cloud"
}
variable "folder_id" {
  description = "Folder"
}
variable "zone" {
  description = "Zone"
  # Значение по умолчанию
  default = "ru-central1-a"
}
variable "public_key_path" {
  # Описание переменной
  description = "Path to the public key used for ssh access"
}
variable "image_id" {
  description = "Disk image"
}
variable "app_disk_image" {
  description = "Disk image for reddit app"
  default = "reddit-app-base"
}
variable "db_disk_image" {
  description = "Disk image for reddit db"
  default = "reddit-db-base"
}
variable "subnet_id" {
  description = "Subnet"
}
variable "service_account_key_file" {
  description = "key .json"
}
variable "private_key_path" {
  description = "Path to the private key file"
}
variable "instances_count" {
  description = "Count instances"
  default     = 1
}
