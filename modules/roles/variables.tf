variable "roles" {
  type = map(object({
    cloud        = string                     # "aws" or "azure"
    description  = string
    principals   = list(string)               # AWS: ARNs, Azure: object IDs
    policies     = optional(list(string))     # AWS only
    custom_trust = optional(string)           # AWS only
    scope        = optional(string)           # Azure only
    role_name    = optional(string)           # Azure only
  }))
}

variable "assignments" {
  type = map(object({
    principal_id = string
    role_name    = string
    scope        = string
  }))
  default = {}
}