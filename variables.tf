variable "project_id" {
  type        = string
  description = "name of the project"
}

variable "env" {
  type        = string
  description = "environemnt of the resource (dev/prod)"
}

variable "region" {
  type        = string
  description = "region of the vm to be deployed in"
}

variable "vm_name" {
  type        = string
  description = "name of the windows vm"
}

variable "vm_disk_name" {
  type        = string
  description = "name of the data disk for vm"
}

variable "disk_size_gb" {
  type        = string
  description = "size of the data disk"
  default     = "50"
}

variable "physical_block_size_bytes" {
  type        = string
  description = "physical block size in byte"
  default     = "4096"
}
variable "vm_disk_type" {
  type        = string
  description = "type of disk for the data disk"
  default     = "pd-standard"
}

variable "machine_type" {
  type        = string
  description = "type of machine the vm will use"
}

variable "env_label" {
  type        = string
  description = "name of the environment label for the vm"
}

variable "vm_image" {
  type        = string
  description = "image to be used on the vm"
}

variable "subnet_range" {
  type = string
  description = "subnet range that is going to be used by the vms"
}