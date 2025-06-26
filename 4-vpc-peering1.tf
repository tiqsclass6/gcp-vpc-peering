# VPC Network 1
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network

resource "google_compute_network" "tiqs-vpc1" {
  provider                = google.project1
  name                    = "tiqs-vpc1"
  auto_create_subnetworks = false
  project                 = "class-6-5-tiqs"
}

# VPC Subnet 1
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork

resource "google_compute_subnetwork" "tiqs-vpc1-subnet" {
  name          = "tiqs-vpc1-subnet"
  ip_cidr_range = "10.245.0.0/24"
  region        = "us-central1"
  network       = google_compute_network.tiqs-vpc1.id
  project       = "class-6-5-tiqs"
}

# GCP VPC Network Peering 1
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_peering

resource "google_compute_network_peering" "tiqs-vpc1-to-tiqs-vpc2" {
  provider     = google.project1
  name         = "tiqs-vpc1-to-tiqs-vpc2"
  network      = google_compute_network.tiqs-vpc1.self_link
  peer_network = google_compute_network.tiqs-vpc2.self_link

  depends_on = [
    google_compute_network.tiqs-vpc1,
    google_compute_network.tiqs-vpc2
  ]
}

# GCP VPC Network Peering Route 1
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_peering_routes_config

resource "google_compute_network_peering_routes_config" "tiqs-vpc1-to-tiqs-vpc2-routes" {
  provider             = google.project1
  network              = google_compute_network.tiqs-vpc1.name
  peering              = google_compute_network_peering.tiqs-vpc1-to-tiqs-vpc2.name
  import_custom_routes = true
  export_custom_routes = true

  depends_on = [
    google_compute_network_peering.tiqs-vpc1-to-tiqs-vpc2
  ]
}
