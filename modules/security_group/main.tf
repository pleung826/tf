########################################
# AWS Security Group
########################################
resource "aws_security_group" "this" {
  count       = var.cloud == "aws" ? 1 : 0
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress
    content {
      description     = lookup(ingress.value, "description", null)
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      cidr_blocks     = lookup(ingress.value, "cidr_blocks", [])
      ipv6_cidr_blocks = lookup(ingress.value, "ipv6_cidr_blocks", [])
      security_groups  = lookup(ingress.value, "security_groups", [])
      self             = lookup(ingress.value, "self", null)
    }
  }

  dynamic "egress" {
    for_each = var.egress
    content {
      description     = lookup(egress.value, "description", null)
      from_port       = egress.value.from_port
      to_port         = egress.value.to_port
      protocol        = egress.value.protocol
      cidr_blocks     = lookup(egress.value, "cidr_blocks", [])
      ipv6_cidr_blocks = lookup(egress.value, "ipv6_cidr_blocks", [])
      security_groups  = lookup(egress.value, "security_groups", [])
      self             = lookup(egress.value, "self", null)
    }
  }

  tags = var.tags
}

########################################
# Azure Network Security Group
########################################
resource "azurerm_network_security_group" "this" {
  count               = var.cloud == "azure" ? 1 : 0
  name                = var.name
  location            = var.region
  resource_group_name = var.resource_group

  dynamic "security_rule" {
    for_each = concat(var.ingress, var.egress)
    content {
      name                       = security_rule.value.name
      description                = lookup(security_rule.value, "description", null)
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }

  tags = var.tags
}

########################################
# GCP Firewall Rule
########################################
resource "google_compute_firewall" "this" {
  count   = var.cloud == "gcp" ? 1 : 0
  name    = var.name
  network = var.network

  dynamic "allow" {
    for_each = var.ingress
    content {
      protocol = allow.value.protocol
      ports    = allow.value.ports
    }
  }

  dynamic "deny" {
    for_each = var.egress
    content {
      protocol = deny.value.protocol
      ports    = deny.value.ports
    }
  }

  source_ranges      = flatten([for rule in var.ingress : lookup(rule, "cidr_blocks", [])])
  destination_ranges = flatten([for rule in var.egress : lookup(rule, "cidr_blocks", [])])

  target_tags = var.target_tags
}
