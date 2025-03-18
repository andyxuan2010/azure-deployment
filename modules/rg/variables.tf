variable "app_rg" {
  type        = string
  description = "The name of the resource group in which the resources will be created."
}

variable "location" {
  type        = string
  description = "The location in which the resources will be created."
  default     = "canadacentral"
}
variable "rg_tags" {
  type        = map(string)
  description = "The tags to be applied to the resource group."
}
variable "rg_reader_group" {
  type        = string
  description = "The name of the group that will have reader access to the resources."
  #default     = "G-Azure-Owner-F"
  default = ""
}
# variable "rg_contributor_group" {
#   type        = string
#   description = "The name of the group that will have contributor access to the resources."
#   default     = "G-Azure-Owner-F"
# }

variable "app_env" {
  type        = string
  description = "The environment in which the resources will be created."
  default     = "dev"
}