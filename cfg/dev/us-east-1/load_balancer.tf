locals {
  load_balancers = {
    alb_web = {
      provider        = "aws"
      lb_type         = "application"
      name            = "dev-web-alb"
      region          = var.region
      internal        = false
      vpc_id          = local.vpcs.app.id
      subnet_ids      = local.vpcs.app.subnets.public.cidrs
      security_groups = [local.security_groups.id]

      listeners = [
        {
          port            = 443
          protocol        = "HTTPS"
          target_group    = "web"
          ssl_policy      = "ELBSecurityPolicy-2016-08"
          certificate_arn = var.acm_cert_arn
        }
      ]

      target_groups = {
        web = {
          port     = 80
          protocol = "HTTP"
          targets = [
            { id = "i-abc123", port = 80 },
            { id = "i-def456", port = 80 }
          ]
          health_check = {
            path                = "/"
            protocol            = "HTTP"
            interval            = 30
            timeout             = 5
            healthy_threshold   = 3
            unhealthy_threshold = 2
          }
        }
      }
    }

    nlb_internal = {
      provider    = "aws"
      lb_type     = "network"
      name        = "dev-internal-nlb"
      region      = var.region
      internal    = true
      vpc_id      = local.vpcs.app.id
      subnet_ids  = local.vpcs.app.subnets.private.cidrs
      listeners   = []
      target_groups = {}
    }

    azure_lb = {
      provider        = "azure"
      lb_type         = "application"
      name            = "dev-azure-lb"
      region          = var.region
      internal        = false
      resource_group  = var.azure_resource_group
      public_ip_id    = var.azure_public_ip_id
      subnet_ids      = local.vpcs.app.subnets.private.cidrs
      listeners       = []
      target_groups   = {}
    }

    gcp_lb = {
      provider      = "gcp"
      lb_type       = "application"
      name          = "dev-gcp-lb"
      region        = var.region
      internal      = false
      ip_address    = var.gcp_reserved_ip
      subnet_ids    = local.vpcs.app.subnets.private.cidrs
      listeners     = []
      target_groups = {}
    }
  }
}
