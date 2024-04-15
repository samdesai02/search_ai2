
# topics
resource "google_pubsub_topic" "product_feed" {
  for_each = local.pub_sub_topics
  name = "${local.env_prefix}_${each.value.topic}"

}


