resource "google_api_gateway_api" "api_gw" {
  provider = google-beta
  api_id = "api-gw-${local.name_suffix}"
}

resource "google_api_gateway_api_config" "api_gw" {
  provider = google-beta
  api = google_api_gateway_api.api_gw.api_id
  api_config_id = "api-gw-${local.name_suffix}"

  openapi_documents {
    document {
      path = "spec.yaml"
      contents = filebase64("test-fixtures/apigateway/openapi.yaml")
    }
  }
}

resource "google_api_gateway_gateway" "api_gw" {
  provider = google-beta
  region     = "us-central1"
  api_config = google_api_gateway_api_config.api_gw.id
  gateway_id = "api-gw-${local.name_suffix}"
  display_name = "MM Dev API Gateway"
  labels = {
    environment = "dev"
  }
}
