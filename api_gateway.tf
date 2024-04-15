
resource "google_api_gateway_api" "api" {
  provider     = google-beta
  project      = local.project_id
  api_id       = "${local.env_prefix}recoapi"
  display_name = "${local.env_prefix}_RecoAPI"
}

resource "google_api_gateway_api_config" "api_config" {
  provider      = google-beta
  project       = local.project_id
  api           = google_api_gateway_api.api.api_id
  api_config_id = "api-cfg-${google_api_gateway_api.api.api_id}-${filemd5("../api_gateway/api_config.yaml")}"
  display_name  = "api-cfg-${google_api_gateway_api.api.api_id}-${filemd5("../api_gateway/api_config.yaml")}"
  openapi_documents {
    document {
      path = "spec.yaml"
      contents = base64encode(templatefile("../api_gateway/api_config.yaml", {
        region                       = local.region
        project_id               =  local.project_id
        env_prefix      = local.env_prefix
      }))
    }

  }

  lifecycle {
    create_before_destroy = true
  }
  depends_on = [
    google_api_gateway_api.api,
  ]
}

resource "google_api_gateway_gateway" "gateway" {
  provider     = google-beta
  project      = local.project_id
  api_config   = google_api_gateway_api_config.api_config.id
  gateway_id   = "gw-${google_api_gateway_api.api.api_id}"
  display_name = "gw-${google_api_gateway_api.api.api_id}"
  region       =  local.api_gateway_region
  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    google_api_gateway_api_config.api_config
  ]
}
