resource "google_compute_region_autoscaler" "foobar" {
  name   = "my-region-autoscaler-${local.name_suffix}"
  region = "us-central1"
  target = google_compute_region_instance_group_manager.foobar.id

  autoscaling_policy {
    max_replicas    = 5
    min_replicas    = 1
    cooldown_period = 60

    cpu_utilization {
      target = 0.5
    }
  }
}

resource "google_compute_instance_template" "foobar" {
  name         = "my-instance-template-${local.name_suffix}"
  machine_type = "e2-standard-4"

  disk {
    source_image = "debian-cloud/debian-9"
    disk_size_gb = 250
  }

  network_interface {
    network = "default"

    # secret default
    access_config {
      network_tier = "PREMIUM"
    }
  }

  # secret default
  service_account {
    scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/pubsub",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append",
    ]
  }
}

resource "google_compute_target_pool" "foobar" {
  name = "my-target-pool-${local.name_suffix}"
}

resource "google_compute_region_instance_group_manager" "foobar" {
  name   = "my-region-igm-${local.name_suffix}"
  region = "us-central1"

  version {
    instance_template  = google_compute_instance_template.foobar.id
    name               = "primary"
  }

  target_pools       = [google_compute_target_pool.foobar.id]
  base_instance_name = "foobar"
}

data "google_compute_image" "debian_9" {
  family  = "debian-9"
  project = "debian-cloud"
}
