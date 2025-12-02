variable "roles" {
  type = map(object({
    description = string
    permissions = list(string)
    assign_to   = list(string) # principal identifiers (users, groups, services)
  }))
  default = {
    "app_deployer" = {
      description = "Deploys workloads to Kubernetes"
      permissions = [
        "eks:DescribeCluster",
        "eks:UpdateNodegroupConfig",
        "iam:PassRole"
      ]
      assign_to = ["ci-cd@dev.example.com"]
    }
  }
}