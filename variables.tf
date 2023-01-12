variable "service_name" {
  type = string
  description = "Name of the service that these resources belong to"
}

variable "frontend_url" {
  type = string
  description = "URL for the frontend application without the scheme/protocol. eg. application.redswitch.dev"
}

variable "environment" {
  type = string
  description = "Application environment this resource will be used for, e.g. development, testing, qa, production"
}