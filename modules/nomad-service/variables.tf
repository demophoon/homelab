variable "name" {
  description = "Name of the Nomad service to deploy"
}

variable "image" {
  description = "Docker image to deploy"
}

variable "environment" {
  description = "Name of environment to deploy job to"
  default = "prod"
}

variable "image_version" {
  description = "Version tag of the Docker image to deploy"
}

variable "jobspec" {
  description = "String containing jobspec to deploy"
  default = null
}

variable "services" {
  description = "List of services to define for the job"
  type = list(object({
    name = string
    port = number
    tags = list(string)
  }))
  default = []
}

variable "hostname" {
  description = "Hostname to use for Traefik routing and monitoring"
  default = ""
}

variable "memory" {
  description = "Memory limit for the service in MB"
  default = 128
}

variable "memory_max" {
  description = "Memory max limit for the service in MB"
  default = 0
}

variable "cpu" {
  description = "cpu limit for the service"
  default = 100
}

variable "enable_monitoring" {
  description = "Register service with Uptime Kuma for monitoring"
  default = false
}

variable "vault_role" {
  description = "Vault role to assign to the service"
  default = ""
}

variable "additional_tags" {
  description = "Tags to apply to the service"
  type = list(string)
  default = []
}
