# Outputs
# https://developer.hashicorp.com/terraform/cli/commands/output

# Output Name to Project 1
output "peering_project1_to_project2" {
  value = google_compute_network_peering.tiqs-vpc1-to-tiqs-vpc2.name
}

# Output Name to Project 2
output "peering_project2_to_project1" {
  value = google_compute_network_peering.tiqs-vpc2-to-tiqs-vpc1.name
}
