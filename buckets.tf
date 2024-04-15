# bucket to archieve functions files
resource "google_storage_bucket" "cloud_functions_archive" {
  name                        = "${random_id.bucket_prefix.hex}-gcf-source" 
  location                    = local.region
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "cloud_product_feed" {
  name                        = "${random_id.bucket_prefix.hex}-product-feed" 
  location                    = local.region
  uniform_bucket_level_access = true
}


