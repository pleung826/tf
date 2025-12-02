variable "cloud" {
  type        = string
  description = "Cloud provider: aws, azure, or gcp"
}

variable "name" {
  type        = string
  description = "Name of the SG/NSG/Firewall"
}

variable "description" {
  type        = string
  default     = null
}

# AWS
variable "vpc_id" {
  type    = string
  default = null
}

# Azure
variable "region" {
  type    = string
  default = null
}
variable "resource_group" {
  type    = string
  default = null
}

# GCP
variable "network" {
  type    = string
  default = null
}
variable "target_tags" {
  type    = list(string)
  default = []
}

# Rules
variable "ingress" {
  type    = list(any)
  default = []
}
variable "egress" {
  type    = list(any)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}