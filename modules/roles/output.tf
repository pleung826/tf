output "aws_roles" {
  value = local.is_aws ? aws_iam_role.roles : {}
}

output "azure_assignments" {
  value = local.is_azure ? azurerm_role_assignment.assignments : {}
}