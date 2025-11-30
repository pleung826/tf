locals {
  security_groups = {
    core = {
      cloud = "aws"
      vpc_id = "vpc-0123456789abcdef0"
      groups = {
        web = {
          description = "Allow HTTP/HTTPS from anywhere"
          ingress = [
            { from_port = 80,  to_port = 80,  protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
            { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
          ]
          egress = [
            { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
          ]
          tags = {
            env  = "dev"
            role = "web"
          }
        }

        db = {
          description = "Allow MySQL from private subnets"
          ingress = [
            { from_port = 3306, to_port = 3306, protocol = "tcp", cidr_blocks = ["10.10.11.0/24", "10.10.12.0/24"] }
          ]
          egress = [
            { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
          ]
          tags = {
            env  = "dev"
            role = "db"
          }
        }
      }
    }

    data = {
      cloud = "azure"
      resource_group = "rg-dev-network"
      location = "eastus"
      groups = {
        api = {
          description = "Allow HTTPS from public subnets"
          ingress = [
            { from_port = 443, to_port = 443, protocol = "Tcp", cidr_blocks = ["10.20.1.0/24", "10.20.2.0/24"] }
          ]
          egress = [
            { from_port = 0, to_port = 0, protocol = "*", cidr_blocks = ["0.0.0.0/0"] }
          ]
          tags = {
            env  = "dev"
            role = "api"
          }
        }

        db = {
          description = "Allow SQL from backend subnet"
          ingress = [
            { from_port = 1433, to_port = 1433, protocol = "Tcp", cidr_blocks = ["10.20.11.0/24"] }
          ]
          egress = [
            { from_port = 0, to_port = 0, protocol = "*", cidr_blocks = ["0.0.0.0/0"] }
          ]
          tags = {
            env  = "dev"
            role = "db"
          }
        }
      }
    }
  }
}