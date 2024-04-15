locals {
  env_prefix = "cz"
  project_id = "reco-cz"
  region = "europe-central2"
  zone = "europe-central2-a"
  api_gateway_region = "europe-west1"
  xml_files_country_code = "cz"
  pub_sub_topics = {
    product = {topic = "product_feed_update"}, 
    price = {topic = "price_feed_update"}, 
    retail_check = {topic = "check_product_update"}
  }
  product_feed = {
    product = {
        var_name = "product_feed_update"
        runtime = "python310"
        entrypoint = "process"
        bucket = google_storage_bucket.cloud_product_feed.name
        currency = "CZK"
        language_code = "cs"
        memory_alocated = "5G"
        available_cpu = "2"
        timeout = 540
        min_instances = 0
        max_instances = 1
        concurrencty = 1
        bq_dataset_id="notino_retailapi_ds"
        bq_table_id = ""
        pub_sub_topic_wo_prefix = "product_feed_update"
        },
    price = {
        var_name = "price_feed_update"
        runtime = "python310"
        entrypoint = "process"
        bucket= google_storage_bucket.cloud_product_feed.name
        currency = "CZK"
        language_code = "cs"
        memory_alocated = "8G"
        available_cpu = "2"
        timeout = 540
        min_instances = 0
        max_instances = 1
        concurrencty = 1
        bq_dataset_id="notino_retailapi_ds"
        bq_table_id = ""
        pub_sub_topic_wo_prefix = "price_feed_update"
        },
    
    retail_check = {
      var_name = "check_product_update"
      runtime = "nodejs20"
      entrypoint = "checkProductUpdate"
      bucket = google_storage_bucket.cloud_product_feed.name
      currency = "CZK"
      language_code = "cs"
      memory_alocated = "256M"
      available_cpu = "0.167"
      timeout = 240
      min_instances = 0
      max_instances = 100
      concurrencty = 1
      bq_dataset_id="notino_retailapi_ds"
      bq_table_id = ""
      pub_sub_topic_wo_prefix = "check_product_update"
        },
    user_events_snapshots = {
        var_name = "user_events_snapshots"
        runtime = "python310"
        entrypoint = "process"
        bucket = google_storage_bucket.cloud_product_feed.name
        currency = "CZK"
        language_code = "cs"
        memory_alocated = "4G"
        available_cpu = "2"
        timeout = 540
        min_instances = 0
        max_instances = 1
        concurrencty = 1
        bq_dataset_id="notino_retailapi_ds"
        bq_table_id = "user_events_snapshots_48h_back"
        pub_sub_topic_wo_prefix = "check_product_update"
        }
  }
  

http_functions = {
    boxesAPI = {
        var_name = "BoxesAPI"
        runtime = "nodejs20"
        entrypoint = "homePage"
        },
    cartAPI = {
        var_name = "CartAPI"
        runtime = "nodejs20"
        entrypoint = "cart"
        },
    addtocartAPI = {
        var_name = "AddToCartAPI"
        runtime = "nodejs20"
        entrypoint = "addToCart"
        },
    listingAPI = {
        var_name = "ListingAPI"
        runtime = "nodejs20"
        entrypoint = "browse"
        },
    productdetailAPI = {
        var_name = "ProductDetailAPI"
        runtime = "nodejs20"
        entrypoint = "productDetail"
        },
    searchAPI = {
        var_name = "SearchAPI"
        runtime = "nodejs20"
        entrypoint = "search"
        },

    suggestAPI = {
        var_name = "SuggestAPI"
        runtime = "nodejs20"
        entrypoint = "suggest"
        }

  }
  
}