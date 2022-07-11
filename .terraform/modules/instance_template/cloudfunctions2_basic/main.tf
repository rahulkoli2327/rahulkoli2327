# [START functions_v2_basic]
resource "google_storage_bucket" "bucket" {
  provider = google-beta
  name     = "cloudfunctions2-function-bucket-${local.name_suffix}"  # Every bucket name must be globally unique
  location = "US"
  uniform_bucket_level_access = true
}
 
resource "google_storage_bucket_object" "object" {
  provider = google-beta
  name   = "function-source.zip"
  bucket = google_storage_bucket.bucket.name
  source = "path/to/index.zip-${local.name_suffix}"  # Add path to the zipped function source code
}
 
resource "google_cloudfunctions2_function" "terraform-test2" {
  provider = google-beta
  name = "test-function-${local.name_suffix}"
  location = "us-central1"
  description = "a new function"
 
  build_config {
    runtime = "nodejs16"
    entry_point = "helloHttp"  # Set the entry point 
    source {
      storage_source {
        bucket = google_storage_bucket.bucket.name
        object = google_storage_bucket_object.object.name
      }
    }
  }
 
  service_config {
    max_instance_count  = 1
    available_memory    = "256M"
    timeout_seconds     = 60
  }
}
# [END functions_v2_basic]
