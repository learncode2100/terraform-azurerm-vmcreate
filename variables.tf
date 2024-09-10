variable "rgname" {
  type = string
}

variable "vnetname" {
  type = string
}

variable "vnetsuffix" {
  type = list(string)
}

variable "subnetname" {
  type = string
}

variable "subnetsuffix" {
  type = list(string)
}

variable "vmname" {
  type = string
}


variable "size" {
  type = string
}


variable "adminuser" {
  type = string
  default = "defaultuser"
}

variable "adminkey" {
  type = string
}