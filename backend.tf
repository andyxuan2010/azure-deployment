terraform {
  required_version = ">=1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0"
    }
    azapi = {
      source = "Azure/azapi"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
  backend "azurerm" {
    subscription_id      = "subscription_id"
    tenant_id            = "tenant_id"
    resource_group_name  = "rg-ccoe-iac-cc-sbx"
    storage_account_name = "stccoeiacccsbx"
    container_name       = "terraform"
    key                  = "template/terraform.tfstate"
  }

}


provider "azurerm" {
  subscription_id = "subscription_id"
  features {}
}


# data "azurerm_client_config" "current" {}
# #data.azurerm_client_config.current.client_id
# data "azurerm_subscriptions" "available" {}
# #data.azurerm_subscriptions.available.subscriptions