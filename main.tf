terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.91.0"
    }
  }
}


provider "azurerm" {
  # Configuration option
  subscription_id = var.subscription_id
  features {}
  
}

#Creating the resource group
resource "azurerm_resource_group" "test" {
  name = "${var.project}-${var.environment}-resource-group"
  location = var.location
}

#Create storage account
resource "azurerm_storage_account" "storage_account" {
  name = "${var.project}${var.environment}storage"
  resource_group_name = azurerm_resource_group.test.name
  location = var.location
  account_tier = "Standard"
  account_replication_type = "LRS"
}

#Create container inside storage
resource "azurerm_storage_container" "storage_container" {
    name = "${var.project}-storage-container-functions"
    storage_account_name = azurerm_storage_account.storage_account.name
    container_access_type = "private"
}

#Create application insights
resource "azurerm_application_insights" "application_insights" {
  name                = "${var.project}-${var.environment}-application-insights"
  location            = var.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

#Create app service plan
resource "azurerm_app_service_plan" "app_service_plan" {
  name                = "${var.project}-${var.environment}-app-service-plan"
  resource_group_name = azurerm_resource_group.test.name
  location            = var.location
  kind                = "FunctionApp"
  reserved = true 
  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

#Create function
resource "azurerm_function_app" "function_app" {
  name                       = "${var.project}-${var.environment}-function-app"
  resource_group_name        = azurerm_resource_group.test.name
  location                   = var.location
  app_service_plan_id        = azurerm_app_service_plan.app_service_plan.id
  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = 1,
    "FUNCTIONS_WORKER_RUNTIME" = "python",
    "AzureWebJobsDisableHomepage" = "true",
  }
  os_type = "linux"
  site_config {
    linux_fx_version          = "python|3.8"
    use_32_bit_worker_process = false
  }
  storage_account_name       = azurerm_storage_account.storage_account.name
  storage_account_access_key = azurerm_storage_account.storage_account.primary_access_key
  version                    = "~4"

  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_RUN_FROM_PACKAGE"],
    ]
  }
}