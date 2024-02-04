resource "azurerm_resource_group" "azurerm_resource_group"{
  location = "switzerlandnorth"
  name     = "rg-cloudresumechallenge-001"
}
resource "azurerm_cdn_endpoint" "azurerm_cdn_endpoint" {
  is_compression_enabled = true
  location               = "global"
  name                   = "crckb"
  optimization_type      = "GeneralWebDelivery"
  origin_host_header     = "stcloudresumechallenge.z1.web.core.windows.net"
  profile_name           = "cdn-crcprofile-001"
  resource_group_name    = "rg-cloudresumechallenge-001"
  origin {
    host_name = "stcloudresumechallenge.z1.web.core.windows.net"
    name      = "stcloudresumechallenge-z1-web-core-windows-net"
  }
  depends_on = [
    azurerm_cdn_profile.azurerm_cdn_profile,
  ]
}
resource "azurerm_cosmosdb_account" "azurerm_cosmosdb_account" {
  location            = "switzerlandnorth"
  name                = "cdb-crckb"
  offer_type          = "Standard"
  resource_group_name = "rg-cloudresumechallenge-001"
  tags = {
    defaultExperience       = "Core (SQL)"
    hidden-cosmos-mmspecial = ""
  }
  consistency_policy {
    consistency_level = "Session"
  }
  geo_location {
    failover_priority = 0
    location          = "switzerlandnorth"
  }
}
resource "azurerm_cosmosdb_sql_database" "azurerm_cosmosdb_sql_database" {
  account_name        = "cdb-crckb"
  name                = "AzureResume"
  resource_group_name = "rg-cloudresumechallenge-001"
  depends_on = [
    azurerm_cosmosdb_account.azurerm_cosmosdb_account,
  ]
}
resource "azurerm_cosmosdb_sql_container" "azurerm_cosmosdb_sql_container" {
  account_name          = "cdb-crckb"
  database_name         = "AzureResume"
  name                  = "Counter"
  partition_key_path    = "/id"
  partition_key_version = 2
  resource_group_name   = "rg-cloudresumechallenge-001"
  depends_on = [
    azurerm_cosmosdb_sql_database.azurerm_cosmosdb_sql_database,
  ]
}
resource "azurerm_cosmosdb_sql_role_definition" "azurerm_cosmosdb_sql_role_definition" {
  account_name        = "cdb-crckb"
  assignable_scopes   = ["/subscriptions/17b273e9-f3d7-4d23-af84-4eded7c2b5d8/resourceGroups/rg-cloudresumechallenge-001/providers/Microsoft.DocumentDB/databaseAccounts/cdb-crckb"]
  name                = "Cosmos DB Built-in Data Reader"
  resource_group_name = "rg-cloudresumechallenge-001"
  type                = "BuiltInRole"
  permissions {
    data_actions = ["Microsoft.DocumentDB/databaseAccounts/readMetadata", "Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/executeQuery", "Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/read", "Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/readChangeFeed"]
  }
  depends_on = [
    azurerm_cosmosdb_account.azurerm_cosmosdb_account,
  ]
}
resource "azurerm_cosmosdb_sql_role_definition" "azurerm_cosmosdb_sql_role_definition" {
  account_name        = "cdb-crckb"
  assignable_scopes   = ["/subscriptions/17b273e9-f3d7-4d23-af84-4eded7c2b5d8/resourceGroups/rg-cloudresumechallenge-001/providers/Microsoft.DocumentDB/databaseAccounts/cdb-crckb"]
  name                = "Cosmos DB Built-in Data Contributor"
  resource_group_name = "rg-cloudresumechallenge-001"
  type                = "BuiltInRole"
  permissions {
    data_actions = ["Microsoft.DocumentDB/databaseAccounts/readMetadata", "Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/*", "Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/*"]
  }
  depends_on = [
    azurerm_cosmosdb_account.azurerm_cosmosdb_account,
  ]
}
resource "azurerm_storage_account" "azurerm_storage_account" {
  account_replication_type = "LRS"
  account_tier             = "Standard"
  location                 = "switzerlandnorth"
  name                     = "stcloudresumechallenge"
  resource_group_name      = "rg-cloudresumechallenge-001"
  static_website {
    error_404_document = "srt-resume.html"
    index_document     = "srt-resume.html"
  }
}
resource "azurerm_storage_container" "azurerm_storage_container" {
  name                 = "$web"
  storage_account_name = "stcloudresumechallenge"
}
resource "azurerm_storage_account" "azurerm_storage_account" {
  account_kind                     = "Storage"
  account_replication_type         = "LRS"
  account_tier                     = "Standard"
  allow_nested_items_to_be_public  = false
  cross_tenant_replication_enabled = false
  default_to_oauth_authentication  = true
  location                         = "switzerlandnorth"
  name                             = "stfunccrckb"
  resource_group_name              = "rg-cloudresumechallenge-001"
}
resource "azurerm_storage_container" "azurerm_storage_container" {
  name                 = "azure-webjobs-hosts"
  storage_account_name = "stfunccrckb"
}
resource "azurerm_storage_container" "azurerm_storage_container" {
  name                 = "azure-webjobs-secrets"
  storage_account_name = "stfunccrckb"
}
resource "azurerm_storage_container" "azurerm_storage_container" {
  name                 = "scm-releases"
  storage_account_name = "stfunccrckb"
}
resource "azurerm_storage_share" "azurerm_storage_share" {
  name                 = "func-crc-kb9e85"
  quota                = 5120
  storage_account_name = "stfunccrckb"
}
resource "azurerm_service_plan" "azurerm_service_plan" {
  location            = "switzerlandnorth"
  name                = "ASP-rgcloudresumechallenge001-8676"
  os_type             = "Linux"
  resource_group_name = "rg-cloudresumechallenge-001"
  sku_name            = "Y1"
}
resource "azurerm_linux_function_app" "azurerm_linux_function_app" {
  app_settings = {
    AzureWebJobsFeatureFlags = "EnableWorkerIndexing"
    ENDPOINT                 = "https://cdb-crckb.documents.azure.com:443"
    KEY                      = "kpy8rkRoixHHQXnnb9bKIf0Y5qM2bjvE7dY66Muhr2bUYrgaNVoef8fvvkI6w8SzjhQGGNXmNt0uACDbmPDafg=="
  }
  builtin_logging_enabled    = false
  client_certificate_mode    = "Required"
  https_only                 = true
  location                   = "switzerlandnorth"
  name                       = "func-crc-kb"
  resource_group_name        = "rg-cloudresumechallenge-001"
  service_plan_id            = "/subscriptions/17b273e9-f3d7-4d23-af84-4eded7c2b5d8/resourceGroups/rg-cloudresumechallenge-001/providers/Microsoft.Web/serverfarms/ASP-rgcloudresumechallenge001-8676"
  storage_account_access_key = "SUeBgpbXJ94NPINdPl06xuG7zf59f+Ckg4mb6zFUWkCTPwbPut0xxxqdipeb9hrTLLYJazEMHTZw+AStbwT7Sg=="
  storage_account_name       = "stfunccrckb"
  site_config {
    ftps_state = "FtpsOnly"
    application_stack {
      python_version = "3.11"
    }
    cors {
      allowed_origins = ["*"]
    }
  }
  depends_on = [
    azurerm_service_plan.azurerm_service_plan,
  ]
}
resource "azurerm_function_app_function" "azurerm_function_app_function" {
  config_json = jsonencode({
    bindings = [{
      authLevel = "FUNCTION"
      direction = "IN"
      name      = "req"
      route     = "ResumeCounter"
      type      = "httpTrigger"
      }, {
      direction = "OUT"
      name      = "$return"
      type      = "http"
    }]
    entryPoint        = "ResumeCounter"
    functionDirectory = "/home/site/wwwroot"
    language          = "python"
    name              = "ResumeCounter"
    scriptFile        = "function_app.py"
  })
  function_app_id = "/subscriptions/17b273e9-f3d7-4d23-af84-4eded7c2b5d8/resourceGroups/rg-cloudresumechallenge-001/providers/Microsoft.Web/sites/func-crc-kb"
  name            = "ResumeCounter"
  depends_on = [
    azurerm_linux_function_app.azurerm_linux_function_app,
  ]
}
resource "azurerm_app_service_custom_hostname_binding" "azurerm_app_service_custom_hostname_binding" {
  app_service_name    = "func-crc-kb"
  hostname            = "func-crc-kb.azurewebsites.net"
  resource_group_name = "rg-cloudresumechallenge-001"
  depends_on = [
    azurerm_linux_function_app.azurerm_linux_function_app,
  ]
}
resource "azurerm_cdn_profile" "azurerm_cdn_profile" {
  location            = "global"
  name                = "cdn-crcprofile-001"
  resource_group_name = "rg-cloudresumechallenge-001"
  sku                 = "Standard_Microsoft"
}
