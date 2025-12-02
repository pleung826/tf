locals {
  postgres_instances = {
    aws_db = {
      provider        = "aws"
      name            = "dev-postgres-aws"
      region          = var.region
      vpc_id          = var.vpc_id
      subnet_ids      = var.private_subnets

      db_config = {
        username            = "admin"
        password            = var.db_password
        engine_version      = "15.4"
        instance_class      = "db.t3.medium"
        storage_gb          = 20
        backup_retention    = 7
        publicly_accessible = false
      }
    }

    azure_db = {
      provider        = "azure"
      name            = "dev-postgres-azure"
      region          = var.region
      resource_group  = var.azure_resource_group
      subnet_ids      = [var.azure_subnet_id]

      db_config = {
        username            = "admin"
        password            = var.db_password
        engine_version      = "15"
        instance_class      = "Standard_D2s_v3"
        storage_gb          = 32
        backup_retention    = 7
        publicly_accessible = false
      }
    }

    gcp_db = {
      provider        = "gcp"
      name            = "dev-postgres-gcp"
      region          = var.region
      subnet_ids      = [var.gcp_subnet_id]

      db_config = {
        username            = "admin"
        password            = var.db_password
        engine_version      = "15"
        instance_class      = "db-custom-2-4096"
        storage_gb          = 25
        backup_retention    = 7
        publicly_accessible = false
      }
    }
  }
}
