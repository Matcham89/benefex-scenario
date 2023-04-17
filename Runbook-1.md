# Runbook-1


To deploy outside of `europe-west2` into other regions, leverage the `subnetwork` and `gce` modules as these are region specific.

In `dev.tfvars` add the variables with the relevant values (example values shown below)
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
terraform init
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
