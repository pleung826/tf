module "vpc" {
  source = "../../modules/vpc"

  for_each = local.vpcs

  cloud              = each.value.cloud
  environment        = "dev"
  name               = each.value.name
  region             = each.value.region
  cidr_block         = each.value.cidr_block
  resource_group     = try(each.value.resource_group, null)
  subnets            = each.value.subnets
  peerings           = try(each.value.peerings, {})
  security_group_ref = try(each.value.security_group_ref, {})
  tags               = each.value.tags
  project            = var.project
  enable_nat         = var.enable_nat
  enable_dns         = var.enable_dns
  flow_logs          = var.flow_logs

  providers = {
    aws   = aws.dev
    azure = azurerm.dev
    gcp   = google.dev
  }
}
