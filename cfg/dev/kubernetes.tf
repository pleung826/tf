locals {
  kubernetes_clusters = {
    app-core = {
      cloud        = "aws"
      region       = "us-east-1"
      version      = "1.29"
      vpc_id       = "vpc-0123456789abcdef0"
      subnet_ids   = ["subnet-aaa", "subnet-bbb", "subnet-ccc"]

      node_groups = {
        default = {
          instance_type = "t3.medium"
          desired_size  = 3
          min_size      = 2
          max_size      = 5
          labels        = { role = "app" }
        }
      }

      access_roles = {
        platform-admin = {
          type        = "iam"  # AWS IAM role
          principal   = "arn:aws:iam::123456789012:role/eks-admin"
          namespace   = "kube-system"
          cluster_role = "cluster-admin"
        }
        dev-user = {
          type        = "iam"
          principal   = "arn:aws:iam::123456789012:user/dev-user"
          namespace   = "dev"
          cluster_role = "view"
        }
      }

      enable_cluster_autoscaler = true
      enable_metrics_server     = true
      tags = {
        env  = "dev"
        team = "platform"
      }
    }

    data-analytics = {
      cloud        = "azure"
      region       = "eastus"
      version      = "1.29"
      resource_group = "rg-dev-aks"
      subnet_id    = "/subscriptions/abcd1234/resourceGroups/rg-dev-network/providers/Microsoft.Network/virtualNetworks/dev-vnet/subnets/aks-subnet"

      node_pools = {
        default = {
          vm_size     = "Standard_DS3_v2"
          node_count  = 3
          min_count   = 2
          max_count   = 6
          mode        = "System"
          labels      = { role = "analytics" }
        }
      }

      access_roles = {
        data-admin = {
          type         = "aad"  # Azure AD object ID
          principal    = "00000000-0000-0000-0000-000000000001"
          namespace    = "default"
          cluster_role = "admin"
        }
        ml-user = {
          type         = "aad"
          principal    = "00000000-0000-0000-0000-000000000002"
          namespace    = "ml"
          cluster_role = "view"
        }
      }

      enable_cluster_autoscaler = true
      enable_metrics_server     = true
      tags = {
        env  = "dev"
        team = "data"
      }
    }
  }
}


