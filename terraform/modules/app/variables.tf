variable public_key_path {
  description = "Path to the public key used for ssh access"
}
variable app_disk_image {
  description = "Disk image for reddit app"
  default = "reddit-app-base"
}
variable subnet_id {
  description = "Subnets for modules"
}
variable "instances_app_count" {
  description = "Instances count"
  default     = 1
}
variable "private_key_path" {
  description = "Path to the private key file"
}
variable "db_ip" {
  description = "database ip"
  default     = "127.0.0.1"
}
