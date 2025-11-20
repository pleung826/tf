variable "region" {
  type = "string"
}

variable "project" {
  type = "string"
}

variable "vpc_id" {
  type = "string"
}

variable "group_name" {
  type    = string
  default = "dev-app-sg"
}

variable "group_rules" {
  type = list(object({
    name        = string
    description = string
    protocol    = string
    from_port   = number
    to_port     = number
    cidr_blocks = list(string)
    direction   = string # "ingress" or "egress"
  }))
  default = [
    {
      name        = "allow_http"
      description = "Allow HTTP traffic"
      protocol    = "tcp"
      from_port   = 80
      to_port     = 80
      cidr_blocks = ["0.0.0.0/0"]
      direction   = "ingress"
    },
    {
      name        = "allow_https"
      description = "Allow HTTPS traffic"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      cidr_blocks = ["0.0.0.0/0"]
      direction   = "ingress"
    }
  ]
}

variable "attach_to_roles" {
  type    = list(string)
  default = []
}