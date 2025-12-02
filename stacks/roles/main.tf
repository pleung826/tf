module "roles" {
  source = "../../modules/roles"
  for_each = var.roles
  roles = each.value
}