
output "subnet" {
  value = google_compute_subnetwork.subnet.id
}

output "static_ip_01" {
  value = google_compute_address.winvm_static_01.address
}

output "static_ip_02" {
  value = google_compute_address.winvm_static_02.address
}