resource "google_compute_url_map" "urlmap" {
  name        = "urlmap-${local.name_suffix}"
  description = "parameter-based routing example"
  default_service = google_compute_backend_service.default.id

  host_rule {
    hosts = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name = "allpaths"
    default_service = google_compute_backend_service.default.id

    route_rules {
      priority = 1
      service = google_compute_backend_service.service-a.id
      match_rules {
        prefix_match = "/"
        ignore_case = true
        query_parameter_matches {
          name = "abtest"
          exact_match = "a"
        }
      }
    }
    route_rules {
      priority = 2
      service = google_compute_backend_service.service-b.id
      match_rules {
        ignore_case = true
        prefix_match = "/"
        query_parameter_matches {
          name = "abtest"
          exact_match = "b"
        }
      }
    }
  }
}

resource "google_compute_backend_service" "default" {
  name        = "default-${local.name_suffix}"
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 10

  health_checks = [google_compute_http_health_check.default.id]
}

resource "google_compute_backend_service" "service-a" {
  name        = "service-a-${local.name_suffix}"
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 10

  health_checks = [google_compute_http_health_check.default.id]
}

resource "google_compute_backend_service" "service-b" {
  name        = "service-b-${local.name_suffix}"
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 10

  health_checks = [google_compute_http_health_check.default.id]
}

resource "google_compute_http_health_check" "default" {
  name               = "health-check-${local.name_suffix}"
  request_path       = "/"
  check_interval_sec = 1
  timeout_sec        = 1
}
