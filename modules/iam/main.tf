locals {
  is_aws   = var.cloud == "aws"
  is_azure = var.cloud == "azure"
}

# AWS IAM Roles
resource "aws_iam_role" "roles" {
  for_each = local.is_aws ? var.roles : {}

  name               = each.value.role_name
  description        = each.value.description
  assume_role_policy = file(each.value.custom_trust != null ? each.value.custom_trust : "${path.module}/default_trust.json")
  tags               = { cloud = "aws" }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "attachments" {
  for_each = local.is_aws ? {
    for role_name, role in var.roles :
    "${role_name}" => {
      role     = role_name
      policies = role.policies
    }
  } : {}

  role       = aws_iam_role.roles[each.value.role].name
  policy_arn = each.value.policies[count.index]
  count      = length(each.value.policies)
}

locals {
  custom_policies = {
    for_each = local.is_aws ? var.roles : {}
    name     = each.value.custom_policy_files :
    basename(path) => {
      name        = replace(basename(path), ".json", "")
      description = "Custom policy loaded from ${basename(path)}"
      policy      = file(path)
    }
  }
}

resource "aws_iam_policy" "custom" {
  for_each = local.custom_policies

  name        = each.value.name
  description = each.value.description
  policy      = each.value.policy
}

resource "aws_iam_role_policy_attachment" "custom_attach" {
  for_each = local.custom_policies

  role       = aws_iam_role.app_role.name
  policy_arn = aws_iam_policy.custom[each.key].arn
}


# Azure Role Assignments
resource "azurerm_role_assignment" "assignments" {
  for_each = local.is_azure ? var.assignments : {}

  principal_id = each.value.principal_id
  role_definition_name = each.value.role_name
  scope        = each.value.scope
}