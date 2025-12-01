locals {
  is_aws   = var.cloud == "aws"
  is_azure = var.cloud == "azure"
}

# AWS Transit Gateway
resource "aws_ec2_transit_gateway" "tgw" {
  count       = local.is_aws ? 1 : 0
  description = var.description
  tags        = merge(var.tags, { Name = var.name })
}

resource "aws_ec2_transit_gateway_vpc_attachment" "attachments" {
  for_each = local.is_aws ? var.vpc_attachments : {}

  subnet_ids         = each.value.subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.tgw[0].id
  vpc_id             = each.value.vpc_id
  tags               = merge(var.tags, { Name = "${var.name}-${each.key}" })
}

resource "aws_ec2_transit_gateway_peering_attachment" "peerings" {
  for_each = local.is_aws ? var.peerings : {}

  transit_gateway_id         = aws_ec2_transit_gateway.tgw[0].id
  peer_account_id            = each.value.peer_account_id
  peer_region                = each.value.peer_region
  peer_transit_gateway_id    = each.value.peer_tgw_id
  tags                       = merge(var.tags, each.value.tags)
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "accept_peerings" {
  for_each = local.is_aws ? var.peerings : {}

  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.peerings[each.key].id
}

resource "aws_ec2_transit_gateway_route_table" "rt" {
  for_each = local.is_aws ? var.route_tables : {}

  transit_gateway_id = aws_ec2_transit_gateway.tgw[0].id
  tags               = merge(var.tags, each.value.tags, { Name = each.value.name })
}

resource "aws_ec2_transit_gateway_route_table_association" "rt_assoc" {
  for_each = local.is_aws ? {
    for rt_key, rt in var.route_tables :
      for assoc in rt.associations :
        "${rt_key}-${assoc}" => {
        rt_key = rt_key
        assoc  = assoc
        }
      } : {}

      transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.attachments[each.value.assoc].id
      transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt[each.value.rt_key].id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "rt_propagate" {
  for_each = local.is_aws ? {
    for rt_key, rt in var.route_tables :
      for prop in rt.propagations :
        "${rt_key}-${prop}" => {
        rt_key = rt_key
        prop   = prop
      }
    } : {}

    transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.attachments[each.value.prop].id
    transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt[each.value.rt_key].id
}

resource "aws_ec2_transit_gateway_route" "static_routes" {
  for_each = local.is_aws ? {
    for rt_key, rt in var.route_tables :
      for route_key, route in rt.routes :
        "${rt_key}-${route_key}" => {
        rt_key = rt_key
        route  = route
      }
    } : {}

  destination_cidr_block         = each.value.route.destination_cidr_block
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt[each.value.rt_key].id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.attachments[each.value.route.target_attachment].id
}

# Azure Virtual WAN
resource "azurerm_virtual_wan" "vwan" {
  count               = local.is_azure ? 1 : 0
  name                = var.name
  location            = var.region
  resource_group_name = var.resource_group
  tags                = var.tags
}

resource "azurerm_virtual_hub" "hubs" {
  for_each = local.is_azure ? var.virtual_hubs : {}

  name                = each.value.name
  location            = var.region
  resource_group_name = var.resource_group
  address_prefix      = each.value.address_prefix
  virtual_wan_id      = azurerm_virtual_wan.vwan[0].id
  tags                = merge(var.tags, { Name = "${var.name}-${each.key}" })
}

resource "azurerm_virtual_hub_route_table" "rt" {
  for_each = local.is_azure ? var.route_tables : {}

  name                = each.value.name
  virtual_hub_id      = azurerm_virtual_hub.hubs[each.value.name].id
  resource_group_name = var.resource_group
  labels              = ["Default"]

  routes = [
    for r_key, r in each.value.routes : {
      name            = "route-${r_key}"
      address_prefix  = r.destination_cidr_block
      next_hop_type   = "IPAddress"
      next_hop        = r.target_attachment
    }
  ]

  tags = each.value.tags
}

resource "azurerm_virtual_hub_connection" "peerings" {
  for_each = local.is_azure ? var.hub_peerings : {}

  name                      = "${each.key}-peering"
  virtual_hub_id            = azurerm_virtual_hub.hubs[each.value.source_hub_name].id
  remote_virtual_hub_id     = each.value.peer_hub_id
  allow_virtual_network_access     = each.value.allow_virtual_network_access
  allow_branch_to_branch_traffic   = each.value.allow_branch_to_branch_traffic
  internet_security_enabled        = false
  routing {
    associated_route_table_id = null
    propagated_route_table {
      labels          = []
      route_table_ids = []
    }
  }
  tags = each.value.tags
}