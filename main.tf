provider "google" {
  project = var.project_id
}

module "benefex_firewall" {
  source      = "./modules/firewall"
  vpc_network = module.benefex_network.vpc_network
}

module "benefex_network" {
  source = "./modules/network"
  env    = var.env
  region = var.region # region specific eg: europe-west2/us-west1
}

module "benefex_subnetwork_eu" {
  source      = "./modules/subnetwork"
  env         = var.env
  region      = var.region # region specific eg: europe-west2/us-west1
  vpc_network = module.benefex_network.vpc_network
  subnet_range = var.subnet_range # ip ranges must not conflict/overlap
}

module "benefex_gce_eu" {
  source       = "./modules/gce"
  region       = var.region # region specific eg: europe-west2/us-west1
  vpc_network  = module.benefex_network.vpc_network
  subnet       = module.benefex_subnetwork_eu.subnet
  static_ip_01 = module.benefex_subnetwork_eu.static_ip_01
  static_ip_02 = module.benefex_subnetwork_eu.static_ip_02
  subnet_range = var.subnet_range # ip ranges must not conflict/overlap
  vm_name      = var.vm_name
  vm_disk_name = var.vm_disk_name
  machine_type = var.machine_type
  env_label    = var.env_label
  vm_image     = var.vm_image
}
