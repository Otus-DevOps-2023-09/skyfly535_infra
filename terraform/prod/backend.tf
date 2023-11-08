  terraform {
    backend "s3" {
        endpoint   = "storage.yandexcloud.net"
        bucket     = "backend-skyfly"
        region     = "ru-central1"
        key        = "prod.tfstate"

        skip_region_validation      = true
        skip_credentials_validation = true
    }
  }
