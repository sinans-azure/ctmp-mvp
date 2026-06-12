variable "subscription_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "location" {
  type = string
}

variable "vnet_cidr" {
  type = list(string)
}

variable "postgres_admin_username" {
  type = string
}

variable "postgres_admin_password" {
  type      = string
  sensitive = true
}

variable "domain_name" {
  type    = string
  default = "sneakertail.online"
}

variable "container_image_tag" {
  type        = string
  description = "Container image tag deployed to Azure Container Apps."
  default     = "latest"
}
