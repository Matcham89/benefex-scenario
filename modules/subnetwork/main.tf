resource "google_compute_subnetwork" "subnet" {
  name                     = "${var.env}-${substr(var.region, 0, 2)}-subnet"
  ip_cidr_range            = var.subnet_range
  region                   = var.region
  network                  = var.vpc_network
  private_ip_google_access = true
}

resource "google_compute_address" "winvm_static_01" {
  name   = "${var.public_ip_name}-${substr(var.region, 0, 2)}-01"
  region = var.region

}

resource "google_compute_address" "winvm_static_02" {
  name   = "${var.public_ip_name}-${substr(var.region, 0, 2)}-02"
  region = var.region

}