locals {
  dns_zones = {
    platform = {
      cloud       = "aws"
      zone_name   = "platform.dev.example.com"
      comment     = "Platform zone for dev environment"
      records = {
        "api" = {
          type = "A"
          ttl  = 300
          value = "10.10.1.10"
        }
        "www" = {
          type = "CNAME"
          ttl  = 300
          value = "platform.dev.example.com"
        }
      }
      tags = {
        env  = "dev"
        team = "platform"
      }
    }

    data = {
      cloud       = "azure"
      zone_name   = "data.dev.example.com"
      resource_group = "rg-dev-dns"
      records = {
        "ml" = {
          type = "A"
          ttl  = 300
          value = "10.20.1.20"
        }
        "dashboard" = {
          type = "CNAME"
          ttl  = 300
          value = "data.dev.example.com"
        }
      }
      tags = {
        env  = "dev"
        team = "data"
      }
    }
  }
}