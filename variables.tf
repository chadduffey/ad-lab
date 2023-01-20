## General stuff

variable "resource_prefix" {
  type = string
}

variable "ws_resource_prefix" {
  type = string
}

variable "member_resource_prefix" {
  type = string
}

variable "dc_resource_prefix" {
  type = string
}

variable "extra_dc_resource_prefix" {
  type = string
}

# tags to apply to all resources

variable "tags" {
  description = "Tags to apply on resource"
  type        = map(string)
}

## Variables for DC

variable "node_location_dc" {
  type = string
}

# vnet address space

variable "node_address_space" {
  default = ["10.0.0.0/16"]
}

# subnet range

variable "node_address_prefix" {
  default = "10.0.0.0/24"
}

variable "vmsize_dc" {
  type = string
}

## Variables for member server

variable "node_location_member" {
  type = string
}

variable "vmsize_member" {
  type = string
}


## Variables for ws

variable "node_location_ws" {
  type = string
}


variable "vmsize_ws" {
  type = string
}

# how many dc vms to create

variable "extra_dc_node_count" {
  type = number
}

# how many member server vms to create

variable "member_node_count" {
  type = number
}

# how many workstation vms to create

variable "workstation_node_count" {
  type = number
}

# local admin credentials

variable "adminpassword" {
  type = string
}

variable "adminuser" {
  type = string
}


## Active Directory 

#fqdn of the domain

variable "active_directory_domain" {
  type = string
  description = "The name of the Active Directory domain, for example `consoto.local`"
}

#safemode password

variable "safemode_password" {
  type = string
  description = "The password associated with the local administrator account on the virtual machine"
}

#netbios name of the domain

variable "active_directory_netbios_name" {
  type = string
  description = "The netbios name of the Active Directory domain, for example `consoto`"
}

#Password for the default domain admin
variable "domadminpassword" {
  type = string
}

#Username for the default domain admin
variable "domadminuser" {
  type = string
}
