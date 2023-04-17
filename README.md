
# Overview
 
The following Terraform leavages custom modules populated with google cloud resources.

* API requirements

* Service accounts

* VPC Network

* Compute Engine

* Firewall Rules

<p>&nbsp;</p>

## High Availability 

Regional persistent disk is a storage option that provides synchronous replication of data between two zones in a region. Regional persistent disks support HA services in Compute Engine
https://cloud.google.com/compute/docs/disks/high-availability-regional-persistent-disk


## Networking

Communication between the end user and Compute Engine is possible via the Allocated External IP. The security restriction on the Network is managed by Firewall Rules.

| Rule  | Direction  | Port | Tag | Action |
| :------------ |:------:| -----:| ------:| -------: |
| RDP | Ingress | 3389 | On-Prem IP | Allow
| Allow Outbound | Egress | 443 | https-server | Allow
| Deny Outbound | Ingress | ALL | ALL | Deny
| Deny Inbound | Ingress | ALL | ALL | Deny


<p>&nbsp;</p>

## Security

The Compute VM has its own service account with the basic permissions. This can be amended and granted the required access in order to carry out future tasks. The  service accounts are created as part of the IaC. Google recommended best practices are advised when assigning roles.

<p>&nbsp;</p>


## GitOps

Best practise is to add protection to the main/production branch in the repo.


| Branch  | Environment  | Protected 
| :------------ |:------:| -----:| 
| main | production | yes | 
| dev | dev | no | 


When introducing a feat into the code, it is advised to create a new branch, make changes, create a _PullRequest_ and merge.

Any environment promotion should be subject to a peer review.

## Future Improvements

* Instead of using RDP to connect to the GCE, implement IAP as a secure connection service. This will remove the requirement for an external IP
https://cloud.google.com/compute/docs/instances/connecting-to-windows

* Use Managed Instance Groups in collaboration with IAP. Scalable and highly available
https://cloud.google.com/compute/docs/instance-groups

* GitOps deployment mechanism in collaboration with Workload Identity Federation
https://about.gitlab.com/topics/gitops/
https://cloud.google.com/iam/docs/workload-identity-federation

* Introduction of a HTTP(s) Global Load Balancer to support increase in network traffic  
https://cloud.google.com/load-balancing/docs/https

# Prerequisites

An Authorised connection to the Google Cloud Console.

Use the below command to connect to the console
```bash
gcloud auth application-default login
```

A project is required to be created
This can be done via _Click Ops_ or _Google Cloud Console CLI_

Example commands below:

```bash
gcloud projects create example  --folder=12345
```

```bash
gcloud projects create example-3 --organization=2048
```

Please follow this link for additional information https://cloud.google.com/sdk/gcloud/reference/projects/create


A GCS is required to host the terraform state file

This can be done via _Click Ops_ or _Google Cloud Console CLI_

```bash
gcloud storage buckets create gs://BUCKET_NAME
```

The `$BUCKET_NAME` needs to be populated in the `backend.tf` file

```bash
terraform {
  backend "gcs" {
    bucket = "$BUCKET_NAME"
    prefix = ""
  }
}
```
<p>&nbsp;</>

# Deployment


Navigate to the root file `benefex-infrastructure`

For deployment into the dev environment, review the `dev.tfvars` file to confirm the variables are correct.

You will need to update the $project_id

```bash
project_id   = "$project_id"
env          = "dev"
region       = "europe-west2"
vm_name      = "win-vm"
vm_disk_name = "data"
machine_type = "e2-medium"
env_label    = "techblog"
vm_image     = "projects/windows-cloud/global/images/windows-server-2022-dc-v20230315"
subnet_range = "192.168.1.0/27"
```

Once the variables are confirmed, the deployment can be actioned.

Run the following commands to deploy the infrastructure

```bash
terraform init -backend-config="prefix=dev"
```

The below command tells terraform to use the dev environment variables
```bash
terraform plan -var-file=dev.tfvars -out plan.yaml
```

Review the plan, ensure you are happy with the predicted deployment

```bash
terraform apply ./plan.yaml
```

```bash
Apply complete!
```

You can review the deployment in the cloud console.


## Expanding Deployment

To deploy outside of `europe-west2` into other regions, leverage the `subnetwork` and `gce` modules as these are region specific.

In `benefex-infrastructure/dev.tfvars` add the variables with the relevant values (example values shown below)
```bash
us_region = "us-west1"
us_subnet_range = "10.240.0.0/27"
```

In `main.tf` add the below
```bash
module "benefex_subnetwork_us" {
  source      = "./modules/subnetwork"
  env         = var.env
  region      = var.us_region # region specific eg: europe-west2/us-west1
  vpc_network = module.benefex_network.vpc_network
  subnet_range = var.us_subnet_range # ip ranges must not conflict/overlap
}

module "benefex_gce_us" {
  source       = "./modules/gce"
  region       = var.us_region # region specific eg: europe-west2/us-west1
  vpc_network  = module.benefex_network.vpc_network
  subnet       = module.benefex_subnetwork_us.subnet
  static_ip_01 = module.benefex_subnetwork_us.static_ip_01
  static_ip_02 = module.benefex_subnetwork_us.static_ip_02
  subnet_range = var.subnet_range # ip ranges must not conflict/overlap
  vm_name      = var.vm_name
  vm_disk_name = var.vm_disk_name
  machine_type = var.machine_type
  env_label    = var.env_label
  vm_image     = var.vm_image
}
```

Repeat the terraform deployment steps

```bash
terraform init -backend-config="prefix=dev"
```

```bash
terraform plan -var-file=dev.tfvars -out plan.yaml
```

Review the plan, ensure you are happy with the predicted deployment

```bash
terraform apply ./plan.yaml
```

```bash
Apply complete!
```

## Adding Additional Disks

To add an additional data drive to the existing vm configuration, access `benefex-infrastructure/modules/gce/main.tf`

The `google_compute_disk` resource is used in this module

Create an additional drive for each vm by adding the below configuration

Disk-03
```bash
resource "google_compute_disk" "win_add_disk_03" {
  name = "${var.vm_disk_name}-${substr(var.region, 0, 2)}-03"
  type = var.vm_disk_type
  zone = "${var.region}-a"
  size = var.disk_size_gb
}
```

Disk-04
```bash
resource "google_compute_disk" "win_add_disk_04" {
  name = "${var.vm_disk_name}-${substr(var.region, 0, 2)}-04"
  type = var.vm_disk_type
  zone = "${var.region}-b"
  size = var.disk_size_gb
}
```

Ensure that the disk zone matches the zone of the vm it is going to be attached to (a/b/c)

Attach the newly added drive to each vm by using the `attached_disk` block

This can be placed under the current attached disk

```bash
 attached_disk {
    source      = google_compute_disk.win_add_disk_03.id
    device_name = google_compute_disk.win_add_disk_03.name
  }
```

```bash
 attached_disk {
    source      = google_compute_disk.win_add_disk_04.id
    device_name = google_compute_disk.win_add_disk_04.name
  }
```


Repeat the terraform deployment steps

```bash
terraform init -backend-config="prefix=dev"
```

```bash
terraform plan -var-file=dev.tfvars -out plan.yaml
```

Review the plan, ensure you are happy with the predicted deployment

```bash
terraform apply ./plan.yaml
```

```bash
Apply complete!
```


# Troubleshooting

### Issues with Google Cloud Authentication

* Try to revoke previous permissions
```bash
gcloud auth application-default revoke
```

* Try to set the project target
```bash
gcloud config set project PROJECT_ID
```

### Issues with terraform deployment

* Review module references 
```bash
  vpc_network  = module.benefex_network.vpc_network

```

* Review input variables in `dev.tfvars`
```bash
project_id   = "$PROJECT_ID"
env          = "dev"
region       = "europe-west2"
vm_name      = "win-vm"
vm_disk_name = "data"
machine_type = "e2-medium"
env_label    = "techblog"
vm_image     = "projects/windows-cloud/global/images/windows-server-2022-dc-v20230315"
subnet_range = "192.168.1.0/27"
```
