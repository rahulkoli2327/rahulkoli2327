resource "google_compute_network" "default" {
  provider                = google-beta
  name                    = "compute-network-${local.name_suffix}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "default" {
  provider      = google-beta
  name          = "compute-subnet-${local.name_suffix}"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.default.self_link
}

resource "google_compute_health_check" "hc" {
  provider           = google-beta
  name               = "proxy-health-check-${local.name_suffix}"
  check_interval_sec = 1
  timeout_sec        = 1

  tcp_health_check {
    port = "80"
  }
}

resource "google_compute_region_backend_service" "backend" {
  provider      = google-beta
  name          = "compute-backend-${local.name_suffix}"
  region        = "us-central1"
  health_checks = [google_compute_health_check.hc.self_link]
}

resource "google_compute_forwarding_rule" "default" {
  provider = google-beta
  name     = "compute-forwarding-rule-${local.name_suffix}"
  region   = "us-central1"

  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.backend.self_link
  all_ports             = true
  network               = google_compute_network.default.name
  subnetwork            = google_compute_subnetwork.default.name
}

resource "google_compute_route" "route-ilb-beta" {
  provider     = google-beta
  name         = "route-ilb-beta-${local.name_suffix}"
  dest_range   = "0.0.0.0/0"
  network      = google_compute_network.default.name
  next_hop_ilb = google_compute_forwarding_rule.default.self_link
  priority     = 2000
}
