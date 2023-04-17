variable "env" {
  type        = string
  description = "environemnt of the resource (dev/prod)"
}

variable "region" {
  type        = string
  description = "region for the eu subnet"
}

variable "vpc_network" {
  type = string
  description = "ID of the vpc network being used"
}

variable "subnet_range" {
  type        = string
  description = "ip range for the deployment"
}

variable "public_ip_name" {
  type        = string
  description = "name of the public ip address for the vm"
  default     = "vm-public-address"
}
