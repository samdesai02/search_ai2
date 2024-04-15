resource "google_cloud_scheduler_job" "job" {
  name        = "${local.env_prefix}_ProductCatalogRegularCheck"
  description = "${local.env_prefix}_ProductCatalogRegularCheck"
  schedule    = "0 */1 * * *"
  time_zone = "Europe/Prague"
  region = local.region
  retry_config {
    min_backoff_duration = "5s"
    max_backoff_duration = "3600s"
    max_retry_duration ="0s"
    max_doublings = 5
    retry_count = 0
  }

  pubsub_target {
    # topic.id is the topic's full resource name.
    topic_name = "projects/${local.project_id}/topics/${local.env_prefix}_${local.product_feed.retail_check.var_name}"
    data       = base64encode("{}")
  }
}