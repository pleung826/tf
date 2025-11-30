locals {
  storage = {
    logs = {
      cloud       = "aws"
      bucket_name = "dev-platform-logs"
      versioning  = true
      replication = {
        enabled     = true
        destination = "prod-platform-logs"  # ← just the bucket name
      }
      lifecycle_rules = [
        {
          id      = "expire-logs"
          enabled = true
          prefix  = "logs/"
          transitions = [
            { days = 30, storage_class = "GLACIER" }
          ]
          expiration = { days = 365 }
        }
      ]
      tags = {
        env  = "dev"
        team = "platform"
      }
    }

    data = {
      cloud           = "azure"
      container_name  = "dev-data-archive"
      resource_group  = "rg-dev-storage"
      storage_account = "devdatastore"
      access_tier     = "Hot"
      replication = {
        enabled     = true
        destination = "prod-data-archive"  # container name or account name
      }
      lifecycle_rules = [
        {
          name    = "archive-old"
          enabled = true
          filters = {
            prefix_match = ["archive/"]
          }
          actions = {
            base_blob = {
              tier_to_cool_after_days     = 30
              tier_to_archive_after_days  = 90
              delete_after_days           = 365
            }
          }
        }
      ]
      tags = {
        env  = "dev"
        team = "data"
      }
    }
  }
}