
resource "google_project_service" "enable_apis" {
  for_each = toset([
    "compute.googleapis.com",
  ])
  service                    = each.value
  disable_dependent_services = true

  disable_on_destroy = false
}

resource "google_service_account" "sa_vm" {
  account_id   = "${substr(var.region, 0, 2)}-service-account-vm"
  display_name = "Service Account For VM Use"
}

resource "google_service_account_iam_member" "admin-account-iam" {
  service_account_id = google_service_account.sa_vm.name
  role               = "roles/viewer"
  member             = "serviceAccount:${google_service_account.sa_vm.email}"
}

resource "google_compute_instance" "win_vm_01" {
  name                      = "${var.vm_name}-${substr(var.region, 0, 2)}-01"
  machine_type              = var.machine_type
  zone                      = "${var.region}-a"
  allow_stopping_for_update = true
  labels = {
    environment = var.env_label
  }

  tags = ["rdp", "https-server"]

  boot_disk {
    initialize_params {
      image = var.vm_image
    }
  }
  attached_disk {
    source      = google_compute_disk.win_add_disk_01.id
    device_name = google_compute_disk.win_add_disk_01.name
  }

  network_interface {
    network    = var.vpc_network
    subnetwork = var.subnet

    access_config {
      nat_ip = var.static_ip_01
    }


  }
  service_account {
    email  = google_service_account.sa_vm.email
    scopes = ["cloud-platform"]
  }

}
resource "google_compute_disk" "win_add_disk_01" {
  name = "${var.vm_disk_name}-${substr(var.region, 0, 2)}-01"
  type = var.vm_disk_type
  zone = "${var.region}-a"
  size = var.disk_size_gb
}
resource "google_compute_region_disk" "win_add_disk_01" {
  name                      = "region-${var.vm_disk_name}-${substr(var.region, 0, 2)}-01"
  snapshot                  = google_compute_snapshot.snapdisk_01.id
  type                      = var.vm_disk_type
  region                    = var.region
  physical_block_size_bytes = var.physical_block_size_bytes

  replica_zones = ["${var.region}-c", "${var.region}-b"]
}

resource "google_compute_snapshot" "snapdisk_01" {
  name        = "snapshot-${var.vm_disk_name}-${substr(var.region, 0, 2)}-01"
  source_disk = google_compute_disk.win_add_disk_01.name
  zone        = "${var.region}-a"
}


resource "google_compute_instance" "win_vm_02" {
  name                      = "${var.vm_name}-${substr(var.region, 0, 2)}-02"
  machine_type              = var.machine_type
  zone                      = "${var.region}-b"
  allow_stopping_for_update = true
  labels = {
    environment = var.env_label
  }

  tags = ["rdp", "https-server"]

  boot_disk {
    initialize_params {
      image = var.vm_image
    }
  }
  attached_disk {
    source      = google_compute_disk.win_add_disk_02.id
    device_name = google_compute_disk.win_add_disk_02.name
  }
  network_interface {
    network    = var.vpc_network
    subnetwork = var.subnet
    access_config {
      nat_ip = var.static_ip_02
    }

  }
  service_account {
    email  = google_service_account.sa_vm.email
    scopes = ["cloud-platform"]
  }

}

resource "google_compute_disk" "win_add_disk_02" {
  name = "${var.vm_disk_name}-${substr(var.region, 0, 2)}-02"
  type = var.vm_disk_type
  zone = "${var.region}-b"
  size = var.disk_size_gb

}

resource "google_compute_region_disk" "win_add_disk_02" {
  name                      = "region-${var.vm_disk_name}-${substr(var.region, 0, 2)}-02"
  snapshot                  = google_compute_snapshot.snapdisk_02.id
  type                      = var.vm_disk_type
  region                    = var.region
  physical_block_size_bytes = var.physical_block_size_bytes


  replica_zones = ["${var.region}-a", "${var.region}-c"]
}

resource "google_compute_snapshot" "snapdisk_02" {
  name        = "snapshot-${var.vm_disk_name}-${substr(var.region, 0, 2)}-02"
  source_disk = google_compute_disk.win_add_disk_02.name
  zone        = "${var.region}-b"
}