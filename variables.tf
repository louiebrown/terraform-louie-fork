variable "location" {
  type        = string
  description = "Location of the resources."
}


variable "admin_username" {
  type        = string
  description = "Admin username for the VM."
  default     = "adminuser"
}

variable "ssh_key_location" {
  type        = string
  description = "Location of the SSH key."
  default     = "~/.ssh/id_ed25519.pub"
}

variable "admin_password" {
  type        = string
  description = "The administrator password of the SQL logical server."
  sensitive   = true
  default     = null
}

variable "team_name" {
  type        = string
  description = "Name of the team."
}

variable "public_vnet_cidr" {
  type        = string
  description = "CIDR block for the public VNet."
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for the public subnets."
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "bastion_cidr" {
  type        = string
  description = "CIDR blocks for the public subnets."
  default     = "10.0.2.0/24"
}

variable "private_vnet_cidr" {
  type        = string
  description = "CIDR block for the private VNet."
  default     = "10.1.0.0/16"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for the private subnets."
  default     = ["10.1.0.0/24", "10.1.1.0/24"]
}

variable "vm_size" {
  type        = string
  description = "Size of the VM."
  default     = "Standard_B1ms"
}

variable "vm_source" {
  type        = map(string)
  description = "Source image for the VM."
  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

variable "dns_ttl" {
  type        = number
  default     = 3600
  description = "Time To Live (TTL) of the DNS record (in seconds)."
}

variable "subscription_id" {
  description = "The Azure subscription ID."
  type        = string
}
variable "tenant_id" {
  description = "The Azure Tenant ID."
  type        = string
  sensitive   = true
}