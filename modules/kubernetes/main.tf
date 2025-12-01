locals {
  is_aws   = var.cloud == "aws"
  is_azure = var.cloud == "azure"
}

# AWS EKS Cluster
resource "aws_eks_cluster" "eks" {
  count = local.is_aws ? 1 : 0
  name  = var.cluster_name
  role_arn = "arn:aws:iam::123456789012:role/EKSClusterRole" # replace with dynamic input
  vpc_config {
    subnet_ids = var.subnet_ids
  }
  version = var.version
  tags    = var.tags
}

resource "aws_eks_node_group" "nodes" {
  for_each = local.is_aws ? var.node_groups : {}

  cluster_name    = aws_eks_cluster.eks[0].name
  node_group_name = each.key
  node_role_arn   = "arn:aws:iam::123456789012:role/EKSNodeRole" # replace with dynamic input
  subnet_ids      = var.subnet_ids
  scaling_config {
    desired_size = each.value.desired_size
    min_size     = each.value.min_size
    max_size     = each.value.max_size
  }
  labels = each.value.labels
  tags   = var.tags
}

# Azure AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  count = local.is_azure ? 1 : 0
  name                = var.cluster_name
  location            = var.region
  resource_group_name = var.resource_group
  dns_prefix          = "${var.cluster_name}-dns"
  kubernetes_version  = var.version

  default_node_pool {
    name       = "default"
    node_count = var.node_pools["default"].node_count
    vm_size    = var.node_pools["default"].vm_size
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# Access Roles (abstracted)
# AWS EKS access roles
resource "aws_iam_role" "eks_access_roles" {
  for_each = local.is_aws ? var.access_roles : {}

  name = "${each.key}-eks-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = each.value.access_roles.platform-admin.principal
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "eks_access_policies" {
  for_each = local.is_aws ? var.access_roles : {}

  name = "${each.key}-eks-access-policy"
  role = aws_iam_role.eks_access_roles[each.key].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      for role_name, role_cfg in each.value.access_roles : {
        Sid    = "${role_name}-Access"
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:UpdateClusterConfig",
          "eks:UpdateClusterVersion",
          "eks:CreateNodegroup",
          "eks:UpdateNodegroupConfig",
          "eks:UpdateNodegroupVersion",
          "eks:DeleteNodegroup"
        ]
        Resource = "*"
      }
    ]
  })
}

# Azure AKS access roles
resource "azurerm_role_assignment" "aks_access_roles" {
  for_each = local.is_azure ? var.access_roles : {}

  scope                = azurerm_kubernetes_cluster.myaks.id
  role_definition_name = "Azure Kubernetes Service Cluster User"
  principal_id         = each.value.access_roles.data-admin.principal
}
