# CDN load balancer with Cloud bucket as backend

# VPC
resource "google_compute_network" "default" {
  name                    = "cdn-network-${local.name_suffix}"
  provider                = google-beta
  auto_create_subnetworks = false
}

# backend subnet
resource "google_compute_subnetwork" "default" {
  name          = "cdn-subnet-${local.name_suffix}"
  provider      = google-beta
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.default.id
}

# reserve IP address
resource "google_compute_global_address" "default" {
  provider = google-beta
  name     = "cdn-static-ip-${local.name_suffix}"
}

# forwarding rule
resource "google_compute_global_forwarding_rule" "default" {
  name                  = "cdn-forwarding-rule-${local.name_suffix}"
  provider              = google-beta
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "80"
  target                = google_compute_target_http_proxy.default.id
  ip_address            = google_compute_global_address.default.id
}

# http proxy
resource "google_compute_target_http_proxy" "default" {
  name     = "cdn-target-http-proxy-${local.name_suffix}"
  provider = google-beta
  url_map  = google_compute_url_map.default.id
}

# url map
resource "google_compute_url_map" "default" {
  name            = "cdn-url-map-${local.name_suffix}"
  provider        = google-beta
  default_service = google_compute_backend_bucket.default.id
}

# backend bucket with CDN policy with default ttl settings
resource "google_compute_backend_bucket" "default" {
  name        = "image-backend-bucket-${local.name_suffix}"
  description = "Contains beautiful images"
  bucket_name = google_storage_bucket.default.name
  enable_cdn  = true
  cdn_policy {
    cache_mode        = "CACHE_ALL_STATIC"
    client_ttl        = 3600
    default_ttl       = 3600
    max_ttl           = 86400
    negative_caching  = true
    serve_while_stale = 86400
  }
}

# cdn backend bucket
resource "google_storage_bucket" "default" {
  name                        = "cdn-backend-storage-bucket-${local.name_suffix}"
  location                    = "US"
  uniform_bucket_level_access = true
  // delete bucket and contents on destroy.
  force_destroy = true
  // Assign specialty files
  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}

# make bucket public
resource "google_storage_bucket_iam_member" "default" {
  bucket = google_storage_bucket.default.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

resource "google_storage_bucket_object" "index_page" {
  name       = "index.html"
  source     = "index.html"
  bucket     = google_storage_bucket.default.name
  depends_on = [local_file.index_page]
}

resource "google_storage_bucket_object" "error_page" {
  name       = "404.html"
  source     = "404.html"
  bucket     = google_storage_bucket.default.name
  depends_on = [local_file.error_page]
}

# image object for testing, try to access http://<your_lb_ip_address>/test.jpg
resource "google_storage_bucket_object" "test_image" {
  name         = "test.jpg"
  source       = "test.jpg"
  content_type = "image/jpeg"
  bucket       = google_storage_bucket.default.name
  depends_on   = [null_resource.test_image]
}

# cdn sample index page
resource "local_file" "index_page" {
  filename = "index.html"
  content  = <<-EOT
    <html><body>
    <h1>Congratulations on setting up Google Cloud CDN with Storage backend!</h1>
    </body></html>
  EOT
}

# cdn default error page
resource "local_file" "error_page" {
  filename = "404.html"
  content  = <<-EOT
    <html><body>
    <h1>404 Error: Object you are looking for is no longer available!</h1>
    </body></html>
  EOT
}

# cdn sample image
resource "null_resource" "test_image" {
  provisioner "local-exec" {
    command = "wget -O test.jpg  https://upload.wikimedia.org/wikipedia/commons/c/c8/Thank_you_001.jpg"
  }
}
