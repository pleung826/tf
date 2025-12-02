module "postgres" {
  source = "../../modules/postgres"

  for_each = var.postgres_instances
  provider        = each.value.provider
  name            = each.value.name
  region          = each.value.region
  vpc_id          = try(each.value.vpc_id, "")
  subnet_ids      = try(each.value.subnet_ids, [])
  resource_group  = try(each.value.resource_group, "")
  db_config       = each.value.db_config

  tags = {
    Owner       = "infra-team"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }

  providers = {
    aws   = aws.dev
    azure = azurerm.dev
    gcp   = google.dev
  }
}
