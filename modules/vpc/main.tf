locals {
  is_aws   = var.cloud == "aws"
  is_azure = var.cloud == "azure"
}

# AWS VPC
resource "aws_vpc" "vpc" {
  count      = local.is_aws ? 1 : 0
  cidr_block = var.cidr_block
  tags       = merge(var.tags, { Name = var.name })
}

resource "aws_subnet" "subnets" {
  for_each = local.is_aws ? {
    for subnet_key, subnet in var.subnets :
      for i, cidr in subnet.cidrs :
        "${subnet_key}-${i}" => {
        cidr = cidr
        az   = subnet.azs[i]
        }
      } : {}

      vpc_id            = aws_vpc.vpc[0].id
      cidr_block        = each.value.cidr
      availability_zone = each.value.az
      tags              = merge(var.tags, { Name = "${var.name}-${each.key}" })
}

resource "aws_vpc_peering_connection" "peerings" {
  for_each = local.is_aws ? var.peerings : {}

  vpc_id      = aws_vpc.vpc[0].id
  peer_vpc_id = each.value.peer_vpc_id
  auto_accept = lookup(each.value, "auto_accept", false)
  tags        = merge(var.tags, each.value.tags)
}

resource "aws_vpc_peering_connection_accepter" "accept_peerings" {
  for_each = local.is_aws && anytrue([for p in var.peerings : lookup(p, "auto_accept", false)]) ? var.peerings : {}

  vpc_peering_connection_id = aws_vpc_peering_connection.peerings[each.key].id
  auto_accept               = true
}

# Azure VNet
resource "azurerm_virtual_network" "vnet" {
  count               = local.is_azure ? 1 : 0
  name                = var.name
  address_space       = [var.cidr_block]
  location            = var.region
  resource_group_name = var.resource_group
  tags                = var.tags
}

resource "azurerm_subnet" "subnets" {
  for_each = local.is_azure ? {
    for subnet_key, subnet in var.subnets :
      for i, cidr in subnet.cidrs :
      "${subnet_key}-${i}" => cidr
      } : {}

      name                 = each.key
      resource_group_name  = var.resource_group
      virtual_network_name = azurerm_virtual_network.vnet[0].name
      address_prefixes     = [each.value]
}

resource "azurerm_virtual_network_peering" "peerings" {
  for_each = local.is_azure ? var.peerings : {}

  name                      = "${var.name}-to-${each.key}"
  resource_group_name       = var.resource_group
  virtual_network_name      = azurerm_virtual_network.vnet[0].name
  remote_virtual_network_id = each.value.peer_vnet_id
  allow_forwarded_traffic        = lookup(each.value, "allow_forwarded_traffic", false)
  allow_virtual_network_access   = lookup(each.value, "allow_virtual_network_access", true)
  tags = each.value.tags
}