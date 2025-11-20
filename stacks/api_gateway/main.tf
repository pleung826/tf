module "api_gateway" {
  source = "../../modules/api_gateway"

  environment     = "dev"
  region          = var.region
  project         = var.project
  gateway_name    = var.gateway_name
  apis            = var.apis # map(object) of API configs
  stage_name      = var.stage_name
  custom_domains  = var.custom_domains # optional map

  providers = {
    aws   = aws.dev
    azure = azurerm.dev
    gcp   = google.dev
  }

  tags = {
    Owner       = "infra-team"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}