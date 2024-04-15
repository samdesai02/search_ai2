#products update and user events snapshot

data "archive_file" "function_src" {
  for_each = local.product_feed
  type        = "zip"
  output_path = "../cloud_functions/tmp/${each.value.var_name}.zip"
  source_dir  = "../cloud_functions/${each.value.var_name}"
}
resource "google_storage_bucket_object" "cloud_functions_archive" {
  for_each = local.product_feed
  name   = "${each.value.var_name}_${data.archive_file.function_src[each.key].output_md5}.zip"
  bucket = google_storage_bucket.cloud_functions_archive.name
  source = "../cloud_functions/tmp/${each.value.var_name}.zip"
}


resource "google_cloudfunctions2_function" "default" {
  for_each = local.product_feed
  name        = "${local.env_prefix}_${each.value.var_name}"
  location    = local.region
  description = "fucntion"

  build_config {
    runtime     = "${each.value.runtime}"
    entry_point = "${each.value.entrypoint}"

    source {
      storage_source {
        bucket = google_storage_bucket.cloud_functions_archive.name
        object = "${each.value.var_name}_${data.archive_file.function_src[each.key].output_md5}.zip"
      }
    }
  }

  service_config {
    max_instance_count = each.value.max_instances
    min_instance_count = each.value.min_instances
    available_memory   = each.value.memory_alocated
    timeout_seconds    = each.value.timeout
    available_cpu = each.value.available_cpu
    max_instance_request_concurrency = each.value.concurrencty
      
    environment_variables = {
      GCP_PROJECT = local.project_id
      BUCKET_NAME = "${each.value.bucket}"
      PRODUCT_TOPIC = "${local.env_prefix}_product_feed_update"
      PRICE_TOPIC = "${local.env_prefix}_price_feed_update"
      CURRENCY = each.value.currency
      LANGUAGE_CODE = each.value.language_code
      XML_FILES_COUNTRY_CODE = local.xml_files_country_code
      BIGQUERY_DATASET = each.value.bq_dataset_id
      BIGQUERY_TABLE = each.value.bq_table_id
      REGION = local.region
    }
    ingress_settings = "ALLOW_ALL"
    all_traffic_on_latest_revision = true
  }

  event_trigger {
    trigger_region = local.region
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = "projects/${local.project_id}/topics/${local.env_prefix}_${each.value.pub_sub_topic_wo_prefix}"
    retry_policy   = "RETRY_POLICY_RETRY"
  }
  depends_on = [resource.google_storage_bucket_object.cloud_functions_archive, 
  resource.google_pubsub_topic.product_feed
  ]
}

# Http functions

data "archive_file" "http_achive_file" {
  for_each = local.http_functions
  type        = "zip"
  output_path = "../cloud_functions/tmp/${each.value.var_name}.zip"
  source_dir  = "../cloud_functions/${each.value.var_name}"
}
resource "google_storage_bucket_object" "http_cloud_functions_archive" {
  for_each = local.http_functions
  name   = "${each.value.var_name}_${data.archive_file.http_achive_file[each.key].output_md5}.zip"
  bucket = google_storage_bucket.cloud_functions_archive.name
  source = "../cloud_functions/tmp/${each.value.var_name}.zip"
}

resource "google_cloudfunctions2_function" "http_functions" {
  for_each = local.http_functions
  name        = "${local.env_prefix}_${each.value.var_name}"
  location    = local.region
  description = "fucntion"

  build_config {
    runtime     = "${each.value.runtime}"
    entry_point = "${each.value.entrypoint}"

    source {
      storage_source {
        bucket = google_storage_bucket.cloud_functions_archive.name
        object = "${each.value.var_name}_${data.archive_file.http_achive_file[each.key].output_md5}.zip"
      }
    }
  }

  service_config {
    max_instance_count = 100
    min_instance_count = 5
    available_memory   = "1G"
    timeout_seconds    = 60
    available_cpu = "2"
    max_instance_request_concurrency = 8
      
    environment_variables = {
      GCP_PROJECT = local.project_id

    }
    ingress_settings               = "ALLOW_ALL"
    all_traffic_on_latest_revision = true
  }
  depends_on = [resource.google_storage_bucket_object.http_cloud_functions_archive]
}