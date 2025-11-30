locals {
  vpcs = {
    app = {
      cloud       = "aws"
      name        = "dev-app-vpc"
      cidr_block  = "10.10.0.0/16"
      region      = "us-east-1"
      subnets = {
        public = {
          cidrs = ["10.10.1.0/24", "10.10.2.0/24"]
          azs   = ["us-east-1a", "us-east-1b"]
        }
        private = {
          cidrs = ["10.10.101.0/24", "10.10.102.0/24"]
          azs   = ["us-east-1a", "us-east-1b"]
        }
      }
      peerings = {
        to-data = {
          peer_vpc_id = "vpc-0fedcba9876543210"
          auto_accept = true
          tags = {
            purpose = "app-to-data"
          }
        }
      }
      tags = {
        env  = "dev"
        team = "app"
      }
    }

    data = {
      cloud          = "azure"
      name           = "dev-data-vnet"
      cidr_block     = "10.20.0.0/16"
      region         = "eastus"
      resource_group = "rg-dev-network"
      subnets = {
        ingest = {
          cidrs = ["10.20.10.0/24"]
        }
        analytics = {
          cidrs = ["10.20.20.0/24"]
        }
      }
      peerings = {
        to-app = {
          peer_vnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dev-network/providers/Microsoft.Network/virtualNetworks/dev-app-vnet"
          allow_forwarded_traffic = true
          allow_virtual_network_access = true
          tags = {
            purpose = "data-to-app"
          }
        }
      }
      tags = {
        env  = "dev"
        team = "data"
      }
    }
  }
}

module "vpc" {
  for_each = local.vpcs

  source = "../../../modules/vpc"

  cloud              = each.value.cloud
  name               = each.value.name
  region             = each.value.region
  cidr_block         = each.value.cidr_block
  resource_group     = try(each.value.resource_group, null)
  subnets            = each.value.subnets
  peerings           = try(each.value.peerings, {})
  security_group_ref = try(each.value.security_group_ref, {})
  tags               = each.value.tags
}
