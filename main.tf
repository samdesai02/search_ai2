provider "google" {
    project = local.project_id
    region = local.region
    zone = local.zone
    credentials = "${file("../service-account.json")}"
}

resource "random_id" "bucket_prefix" {
  byte_length = 8
}

resource "google_storage_bucket" "default" {
  name          = "${random_id.bucket_prefix.hex}-bucket-tfstate"
  force_destroy = false
  location      = local.region
  storage_class = "STANDARD"
  versioning {
    enabled = true
  }
}

locals {
  ########################################################
  # IMPORTANT: When adding new services to the enabled_apis list, ALWAYS add them at the END. Adding them to the middle will lead to problems.
  # first enable resource manager manualy (enter project number at the end of link) -> https://console.developers.google.com/apis/api/cloudresourcemanager.googleapis.com/overview?project=853253108104
  ########################################################
  enabled_apis = [
    "bigquery", "cloudbilling", "billingbudgets", "apigateway", "servicecontrol", "servicemanagement", "iam", "run",  "apikeys",
     "cloudfunctions","cloudbuild", "artifactregistry", "eventarc","cloudscheduler"
  ]
}

resource "google_project_service" "enable" {
  count   = length(local.enabled_apis)
  project = local.project_id
  service = "${element(local.enabled_apis, count.index)}.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
}

