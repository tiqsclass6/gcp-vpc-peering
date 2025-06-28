# 🌐 GCP VPC Peering: Project 1 to Project 2

[![Terraform](https://img.shields.io/badge/Terraform-v1.6+-623CE4?logo=terraform)](https://www.terraform.io/)
[![GCP](https://img.shields.io/badge/GCP-Enabled-4285F4?logo=googlecloud)](https://cloud.google.com/)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

![diagram](/Screenshots/Diagram.svg)

## 📘 Overview

This project sets up VPC peering between two Google Cloud projects using Terraform. VPC peering allows for private **RFC 1918** IP communication between projects across regions without using public IPs or VPNs. This setup is ideal for multi-project architectures, shared service models, and secure microservice-to-microservice communication.

---

## 🛠 Project Structure

```plaintext
├── .gitignore                # Git ignore rules for Terraform and sensitive files
├── 1-authentication.tf       # Auth setup with service account
├── 2-backend.tf              # Remote backend configuration
├── 3-variables.tf            # Input variables for flexibility
├── 4-vpc-peering1.tf         # Peering config from Project 1 to Project 2
├── 5-vpc.peering2.tf         # Peering config from Project 2 to Project 1
├── 6-outputs.tf              # Outputs of peering and network information
├── README.md                 # Project overview and documentation
```

---

## ⚙️ Comment Out VPC Peering for Partial Deployment

```bash
Error removing peering tiqs-vpc1-to-tiqs-vpc2 from network tiqs-vpc1:
googleapi: Error 400: There is a peering operation in progress on the local or peer network.
Try again later., badRequest
```

### 🔍 The "What"

This error occurs when attempting to delete or modify a VPC peering connection while **another operation is already in progress** on the same VPC or its peer.

---

### 🛑 The "Why"

1. **GCP Enforces Operation Sequencing**  
   Only one VPC peering operation can be active at a time per network. This ensures:
   - **Network consistency**
   - **Correct route propagation**
   - **Avoidance of conflicting state changes**

2. **Terraform State Consistency**  
   Terraform relies on accurate state. If a peering deletion fails midway:
   - It may leave your infrastructure in a **partially destroyed state**
   - You may need to **retry or manually clean up** the state

3. **Avoiding Data Path Disruption**  
   Peering affects routing tables. Sequential operations prevent:
   - Routing conflicts
   - Intermittent downtime between services in peered networks

---

### ✅ Step 1: Comment out part of `5-vpc.peering2.tf`

*To temporarily disable the VPC peering from Project 2 to Project 1, follow these steps:*

File path: `5-vpc.peering2.tf`

Comment out the entire `google_compute_network_peering` and `google_compute_network_peering_routes_config` resources.

```bash
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
  import_custom_routes  = false
  export_custom_routes  = false

  depends_on = [
    google_compute_network_peering.tiqs-vpc1-to-tiqs-vpc2
  ]
}
```

---

### ✅ Step 2: Comment out `peering_project2_to_project1` Output

File path: `6-outputs.tf`

Find the corresponding output block for `peering_project2_to_project1` and comment it out:

```bash
output "peering_project2_to_project1" {
  value = google_compute_network_peering.tiqs-vpc2-to-tiqs-vpc1.name
}
```

This prevents Terraform from referencing a resource that has been commented out.

---

## 🚀 Terraform Steps

To deploy the peering configuration:

1. **Initialize Terraform**

   ```bash
   terraform init
   ```

2. **Validate the configuration**

   ```bash
   terraform validate
   ```

3. **Plan the deployment**

   ```bash
   terraform plan
   ```

4. **Apply the infrastructure**

   ```bash
   terraform apply -auto-approve
   ```

5. **Wait and Complete Mutual Peering**

- **After the initial apply completes:**
  - 🕒 Wait 3 minutes to allow the first VPC peering to fully propagate and be recognized by GCP.
  
  - ✏️ Uncomment the `google_compute_network_peering.peering_project2_to_project1` and `google_compute_network_peering_routes_config.tiqs-vpc2-to-tiqs-vpc1-routes` resource block in `5-vpc.peering2.tf`.
  
  - ✏️ Uncomment the corresponding output `peering_project2_to_project1` block in `6-outputs.tf`.
    - Then run:

      ```bash
      terraform apply -auto-approve
      ```

      ![tf-apply](/Screenshots/tf-apply.jpg)

---

## 🔍 Verification Steps

After a successful second `terraform apply`, verify that both VPC peerings are active:

### 🔎 Step 1: Verify VPCs and Subnet CIDR Blocks

Before troubleshooting the peering issue or retrying destroy/apply, ensure that the VPCs and their subnets are correctly configured with valid CIDR ranges.

- Check that:
  - VPCs exist in each project
  - Subnet CIDRs are unique and not overlapping
  - Subnets are deployed and visible under each VPC

📸 **VPC and Subnet Visuals:**

![vpc1-with-subnets](/Screenshots/vpc1-with-subnet.jpg)  
![vpc2-with-subnets](/Screenshots/vpc2-with-subnet.jpg)

---

### ✅ Step 2: Step-by-Step in GCP Console

1. Navigate to **VPC Network > VPC Network Peering**.  
2. Verify peering entries exist for **both** projects.  
3. Ensure both connections show a **status of ACTIVE**.

   ![vpc-peering1](/Screenshots/peering1-to-peering2.jpg)  
   ![vpc-peering2](/Screenshots/peering2-to-peering1.jpg)

4. Check that routes are being exchanged and traffic is flowing if applicable.

---

## 💣 Terraform Destroy (Tear Down)

To remove all deployed infrastructure:

### Destroy the infrastructure

```bash
terraform destroy -auto-approve
```

![tf-destroy](/Screenshots/tf-destroy.jpg)

### Notes

- This will remove VPC peering links and any associated outputs.
- Ensure no dependent workloads are running before proceeding.
- **Note:** You may need to run `terraform destroy` twice to fully remove both VPC peerings.

---

## 🧰 Troubleshooting

| Issue | Solution |
|-------|----------|
| **`Error: Resource not found`** | Make sure both peering configurations are enabled or adjust outputs accordingly. |
| **Peering shows `INACTIVE`** | Ensure both peering configurations are *mutual* and VPCs are in the same region or compatible regions. |
| **Routing not working** | Verify that subnet routes are exported/imported between the peered VPCs. |
| **Permission errors** | Check if the service account has `Compute Network Admin` and `Project Viewer` roles on both projects. |
| **Plan fails due to missing output** | Ensure you’ve commented out the corresponding output in `6-outputs.tf` when disabling a resource. |

---

## ✍️ Authors & Acknowledgments

- **Author:** T.I.Q.S.
- **Group Leader:** John Sweeney

---
