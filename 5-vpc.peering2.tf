# VPC Network 2
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network

resource "google_compute_network" "tiqs-vpc2" {
  provider                = google.project2
  name                    = "tiqs-vpc2"
  auto_create_subnetworks = false
  project                 = "class-6-5-tiqs-part-2"
}

# VPC Subnet 2
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork

resource "google_compute_subnetwork" "tiqs-vpc2-subnet" {
  name          = "tiqs-vpc2-subnet"
  ip_cidr_range = "10.244.0.0/24"
  region        = "southamerica-east1"
  network       = google_compute_network.tiqs-vpc2.id
  project       = "class-6-5-tiqs-part-2"
}

# GCP VPC Network Peering 2
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_peering

resource "google_compute_network_peering" "tiqs-vpc2-to-tiqs-vpc1" {
  provider     = google.project2
  name         = "tiqs-vpc2-to-tiqs-vpc1"
  network      = google_compute_network.tiqs-vpc2.self_link
  peer_network = google_compute_network.tiqs-vpc1.self_link
  
  depends_on = [
    google_compute_network.tiqs-vpc1,
    google_compute_network.tiqs-vpc2
  ]
}

# GCP VPC Network Peering Route 2
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_peering_routes_config

resource "google_compute_network_peering_routes_config" "tiqs-vpc2-to-tiqs-vpc1-routes" {
  provider              = google.project2
  network               = google_compute_network.tiqs-vpc2.name
  peering               = google_compute_network_peering.tiqs-vpc2-to-tiqs-vpc1.name
  import_custom_routes  = true
  export_custom_routes  = true


  depends_on = [
    google_compute_network_peering.tiqs-vpc1-to-tiqs-vpc2
  ]
}
