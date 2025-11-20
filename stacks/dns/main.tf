module "dns" {
  source = "../../modules/dns"

  environment     = "dev"
  region          = var.region
  project         = var.project
  domain_name     = var.domain_name
  zone_type       = var.zone_type # "public" or "private"
  record_sets     = var.record_sets # map(object) of records

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