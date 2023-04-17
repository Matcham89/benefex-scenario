variable "env" {
  type        = string
  description = "environemnt of the resource (dev/prod)"
}

variable "routing_mode" {
  type        = string
  description = "routing mode of the vpc"
  default     = "GLOBAL"
}

variable "region" {
  type        = string
  description = "region for the eu subnet"
}

variable "public_ip_name" {
  type        = string
  description = "name of the public ip address for the vm"
  default     = "vm-public-address"
}
