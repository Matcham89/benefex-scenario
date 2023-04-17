resource "google_compute_firewall" "rdp_firewall" {
  name    = "rdp"
  network = var.vpc_network
  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }
  priority      = 1000
  direction     = "INGRESS"
  source_ranges = ["80.193.23.74/32"]
  target_tags   = ["rdp"]
}

resource "google_compute_firewall" "allow_outbound" {
  name    = "allow-outbound"
  network = var.vpc_network
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
  priority      = 1000
  direction     = "EGRESS"
  target_tags   = ["https-server"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "deny_outbound" {
  name    = "deny-outbound"
  network = var.vpc_network
  deny {
    protocol = "all"
    ports    = []
  }
  priority      = 2000
  direction     = "EGRESS"
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "deny_inbound" {
  name    = "deny-inbound"
  network = var.vpc_network
  deny {
    protocol = "all"
    ports    = []
  }
  priority      = 2000
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
}
