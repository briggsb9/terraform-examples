variable "location" {
  description = "The Azure region in which all resources will be created."
  type        = string
  default     = "westeurope"
}

variable "resource_prefix" {
  description = "The suffix for resource naming."
  type        = string
  default     = "cloudngfw"
}

variable "resource_suffix" {
  description = "The suffix for resource naming."
  type        = string
  default     = "01"
}

variable "subnet_address_prefix_trust" {
  description = "The address prefix for the trust subnet."
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "subnet_address_prefix_untrust" {
  description = "The address prefix for the untrust subnet."
  type        = list(string)
  default     = ["10.0.2.0/24"]
}
