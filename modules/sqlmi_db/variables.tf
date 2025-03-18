variable "app_sqlmi" {
  type = string
}
variable "app_sqlmi_db" {
  type = string
}
variable "app_sqlmi_rg" {
  type = string
}
variable "app_ad_group" {
  type = string
}
variable "iac_rg" {
  type        = string
  description = "The name of the resource group in which the resources will be created."
}
variable "iac_kv" {
  type        = string
  description = "The name of the key vault in which the secrets will be stored."
}
variable "iac_st" {
  type        = string
  description = "The name of the storage account in which the Terraform state will be stored."
}

# variable "cicdvms" {
#   type    = list(string)
#   default = ["AZUWASHA001", "AZULASHA001"]
# }

variable "sql_ad_group" {
  type        = string
  description = "The name of the group that will have reader access to the SQL resources."
  default     = "administrators"
}