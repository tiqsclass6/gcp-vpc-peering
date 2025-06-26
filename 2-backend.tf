# https://www.terraform.io/language/settings/backends/gcs

terraform {
  backend "gcs" {
    bucket      = "gcs-bucket-name"                  # Insert your bucket name here
    prefix      = "terraform/state"
    credentials = "json-key-here-1.json"             # Add First JSON Key
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}
