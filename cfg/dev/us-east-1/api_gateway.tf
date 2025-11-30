locals {
  api_gateways = {
    app-api = {
      cloud       = "aws"
      name        = "dev-app-api"
      region      = "us-east-1"
      description = "Dev API Gateway for app services"
      stage_name  = "dev"
      routes = {
        health = {
          path        = "/health"
          method      = "GET"
          integration = {
            type = "lambda"
            lambda_arn = "arn:aws:lambda:us-east-1:123456789012:function:healthCheck"
          }
        }
        submit = {
          path        = "/submit"
          method      = "POST"
          integration = {
            type = "http"
            url  = "https://example.com/submit"
          }
        }
      }
      tags = {
        env  = "dev"
        team = "app"
      }
    }

    data-api = {
      cloud          = "azure"
      name           = "dev-data-api"
      region         = "eastus"
      resource_group = "rg-dev-network"
      api_type       = "http"
      routes = {
        ingest = {
          path        = "/ingest"
          method      = "POST"
          backend_url = "https://data-ingest.example.com"
        }
        status = {
          path        = "/status"
          method      = "GET"
          backend_url = "https://data-status.example.com"
        }
      }
      tags = {
        env  = "dev"
        team = "data"
      }
    }
  }
}