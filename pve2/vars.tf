variable "proxmox_host" {
	default	=	"pve2"
}

variable "template_name" {
	default	=	"ubuntu-template"
}

variable "pm_api_url" {
  type = string
  description = "Proxmox API URL"
  sensitive = true
}

variable "pm_api_token_id" {
  type = string
  description = "Proxmox API Token ID"
  sensitive = true
}

variable "pm_api_token_secret" {
  type = string
  description = "Proxmox API Token Secret"
  sensitive = true
}

variable "ssh_keys" {
  type = string
  default = "~/.ssh/id_rsa.pub"
}

variable "password" {
  type = string
  description = "Password for the VM"
  sensitive = true
}

variable "username" {
  type = string
  description = "Username for the VM"
  sensitive = true
  
}

variable "vm_count" {
  type = number
  default = 3
  description = "Number of VMs to create"
}

variable "vm_names" {
	type = list(string)
	default = ["dns-server", "web-server", "db-server"]
}