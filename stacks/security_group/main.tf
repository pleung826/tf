module "security_group" {
  source = "../../modules/security_group"

  for_each = var.security_groups
  environment     = "dev"
  region          = each.value.region
  project         = each.value.project
  cloud           = each.value.cloud
  name            = each.value.name
  description     = each.value.description
  ingress         = each.value.ingress
  egress          = each.value.egress
  tags            = each.value.tags

  # AWS
  vpc_id = each.value.vpc_id

  # Azure
  resource_group = each.value.resource_group

  # GCP
  network = each.value.network

  providers = {
    aws   = aws.dev
    azure = azurerm.dev
    gcp   = google.dev
  }
}