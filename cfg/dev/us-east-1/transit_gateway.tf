locals {
  transit_gateways = {
    core-aws = {
      cloud       = "aws"
      name        = "dev-core-tgw"
      region      = "us-east-1"
      description = "Core transit gateway for dev"

      vpc_attachments = {
        app = {
          vpc_id     = "vpc-0123456789abcdef0"
          subnet_ids = ["subnet-aaa", "subnet-bbb"]
        }
        data = {
          vpc_id     = "vpc-0fedcba9876543210"
          subnet_ids = ["subnet-ccc", "subnet-ddd"]
        }
      }

      route_tables = {
        shared = {
          name         = "tgw-shared-rt"
          associations = ["app"]
          propagations = ["data"]
          routes = {
            to-data = {
              destination_cidr_block = "10.200.0.0/16"
              target_attachment      = "data"
            }
          }
          tags = {
            purpose = "shared-routing"
          }
        }
      }

      peerings = {
        to-prod = {
          peer_account_id = "123456789012"
          peer_region     = "us-west-2"
          peer_tgw_id     = "tgw-0abc123def456ghij"
          tags = {
            purpose = "dev-to-prod"
          }
        }
      }

      tags = {
        env  = "dev"
        team = "platform"
      }
    }

    global-azure = {
      cloud          = "azure"
      name           = "dev-global-vwan"
      region         = "eastus"
      resource_group = "rg-dev-network"

      virtual_hubs = {
        app = {
          name           = "vhub-app"
          address_prefix = "10.100.0.0/16"
        }
        data = {
          name           = "vhub-data"
          address_prefix = "10.200.0.0/16"
        }
      }

      route_tables = {
        app = {
          name         = "app-rt"
          associations = []
          propagations = []
          routes = {
            to-data = {
              destination_cidr_block = "10.200.0.0/16"
              target_attachment      = "10.200.0.1"  # next hop IP
            }
          }
          tags = {
            purpose = "app-routing"
          }
        }
      }

      hub_peerings = {
        app-to-data = {
          source_hub_name               = "app"
          peer_hub_id                   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dev-network/providers/Microsoft.Network/virtualHubs/vhub-data"
          allow_virtual_network_access  = true
          allow_branch_to_branch_traffic = true
          tags = {
            purpose = "app-data peering"
          }
        }
      }

      tags = {
        env  = "dev"
        team = "network"
      }
    }
  }
}