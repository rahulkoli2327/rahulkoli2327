# [START functions_v2_full]
resource "google_service_account" "account" {
  provider = google-beta
  account_id = "s-a-${local.name_suffix}"
  display_name = "Test Service Account"
}

resource "google_pubsub_topic" "sub" {
  provider = google-beta
  name = "pub-sub-${local.name_suffix}"
}

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
 
resource "google_cloudfunctions2_function" "terraform-test" {
  provider = google-beta
  name = "test-function-${local.name_suffix}"
  location = "us-central1"
  description = "a new function"
 
  build_config {
    runtime = "nodejs16"
    entry_point = "helloPubSub"  # Set the entry point 
    environment_variables = {
        BUILD_CONFIG_TEST = "build_test"
    }
    source {
      storage_source {
        bucket = google_storage_bucket.bucket.name
        object = google_storage_bucket_object.object.name
      }
    }
  }
 
  service_config {
    max_instance_count  = 3
    min_instance_count = 1
    available_memory    = "256M"
    timeout_seconds     = 60
    environment_variables = {
        SERVICE_CONFIG_TEST = "config_test"
    }
    ingress_settings = "ALLOW_INTERNAL_ONLY"
    all_traffic_on_latest_revision = true
    service_account_email = google_service_account.account.email
  }

  event_trigger {
    trigger_region = "us-central1"
    event_type = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic = google_pubsub_topic.sub.id
    retry_policy = "RETRY_POLICY_RETRY"
    service_account_email = google_service_account.account.email
  }
}
# [END functions_v2_full]
