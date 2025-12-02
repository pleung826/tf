module "security_group" {
  source = "../../modules/security_group"

  for_each = var.security_groups
  environment     = "dev"
  region          = each.value.region
  project         = each.value.project
  group_name      = each.value.group_name
  group_rules     = each.value.group_rules
  vpc_id          = each.value.vpc_id
  attach_to_roles = each.value.attach_to_roles # optional IAM integration

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