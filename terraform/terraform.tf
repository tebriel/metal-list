terraform {
  required_version = ">= 0.14"
}

# Configure the Azure Provider
provider "azurerm" {
  features {}
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.41.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "terraform"
    storage_account_name = "tebrielterraformstate"
    container_name       = "metal-list"
    key                  = "terraform.tfstate"
  }
}

resource "azurerm_resource_group" "metal-list" {
  name     = "metal-list"
  location = "East US"
}