locals {

  roles = {
    eks-admin = {
      cloud        = "aws"
      description  = "EKS admin role"
      principals   = ["arn:aws:iam::123456789012:user/admin"]
      role_name    = "eks-admin"
      policies     = [
        "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
        "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
      ]
      custom_policy_files = [
        "../../policies/s3_readonly.json",
        "../../policies/dynamodb_access.json",
        "../../policies/cloudwatch_logs.json"
      ]
      custom_trust = "../../policies/aws/trust/eks-admin-trust.json"
    }

    lambda-exec = {
      cloud        = "aws"
      description  = "Lambda execution role"
      principals   = ["arn:aws:iam::123456789012:role/lambda-basic"]
      role_name    = "lambda-exec"
      policies     = [
        "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
      ]
    }

    aks-reader = {
      cloud        = "azure"
      description  = "AKS read-only access"
      principals   = ["00000000-0000-0000-0000-000000000001"]  # Azure AD object ID
      role_name    = "Reader"
      scope        = "/subscriptions/abcd1234/resourceGroups/rg-dev-aks"
    }

    blob-access = {
      cloud        = "azure"
      description  = "Blob storage data reader"
      principals   = ["00000000-0000-0000-0000-000000000002"]
      role_name    = "Storage Blob Data Reader"
      scope        = "/subscriptions/abcd1234/resourceGroups/rg-dev-data/providers/Microsoft.Storage/storageAccounts/devblobstore"
    }
  }
}
