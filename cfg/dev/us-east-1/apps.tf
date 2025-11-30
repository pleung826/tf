locals {
  apps = {
    web-frontend = {
      cloud         = "aws"
      cluster       = "eks-dev"
      namespace     = "frontend"
      image         = "ghcr.io/company/web-frontend:latest"
      replicas      = 3
      expose        = {
        type        = "alb"
        port        = 443
        protocol    = "HTTPS"
        dns_name    = "web.dev.example.com"
      }
      resources = {
        cpu    = "250m"
        memory = "512Mi"
      }
      tags = {
        env  = "dev"
        team = "frontend"
      }
    }

    api-service = {
      cloud         = "azure"
      cluster       = "aks-dev"
      namespace     = "backend"
      image         = "ghcr.io/company/api-service:stable"
      replicas      = 2
      expose        = {
        type        = "apim"
        port        = 443
        protocol    = "HTTPS"
        dns_name    = "api.dev.example.com"
      }
      resources = {
        cpu    = "500m"
        memory = "1Gi"
      }
      database = {
        type     = "postgres"
        version  = "15"
        storage  = "20Gi"
      }
      cache = {
        type     = "redis"
        version  = "7"
        memory   = "1Gi"
      }
      tags = {
        env  = "dev"
        team = "backend"
      }
    }
  }
}

module "app_stack" {
  source = "../../../app_stack"

  apps = local.apps
}