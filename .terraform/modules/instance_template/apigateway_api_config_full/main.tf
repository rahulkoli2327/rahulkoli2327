resource "google_api_gateway_api" "api_cfg" {
  provider = google-beta
  api_id = "api-cfg-${local.name_suffix}"
}

resource "google_api_gateway_api_config" "api_cfg" {
  provider = google-beta
  api = google_api_gateway_api.api_cfg.api_id
  api_config_id = "api-cfg-${local.name_suffix}"
  display_name = "MM Dev API Config"
  labels = {
    environment = "dev"
  }

  openapi_documents {
    document {
      path = "spec.yaml"
      contents = filebase64("test-fixtures/apigateway/openapi.yaml")
    }
  }
}
