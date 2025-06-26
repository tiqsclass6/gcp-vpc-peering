provider "google" {
  alias       = "project1"
  project     = "enter-project-id-1"               # Enter Project ID 1
  region      = "us-central1"                      # Enter First Region
  credentials = file("json-key-here-1.json")       # Add First JSON Key
}

provider "google" {
  alias       = "project2"
  project     = "enter-project-id-2"               # Enter Project ID 2
  region      = "southamerica-east1"               # Enter First Region
  credentials = file("json-key-here-2.json")       # Add Second JSON Key
}
