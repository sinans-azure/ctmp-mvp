locals {

  project = "CTMP"

  tags = {
    Project     = local.project
    Environment = upper(var.environment)
    ManagedBy   = "Terraform"
    Owner       = "Sinan"
  }
}

locals {

  environment_config = {

    dev = {

      rg_name = "RG-CTMP-DEV"

      vnet_name = "VNET-CTMP-DEV"

      address_space = ["10.1.0.0/16"]

      subnets = {

        AGWSubnet = {
          address_prefixes = ["10.1.1.0/24"]
        }

        ContainerAppsSubnet = {
          address_prefixes = ["10.1.8.0/22"]
          delegation       = "Microsoft.App/environments"
        }

        PrivateEndpointsSubnet = {
          address_prefixes = ["10.1.3.0/24"]
        }

        FunctionsSubnet = {
          address_prefixes = ["10.1.5.0/24"]
          delegation       = "Microsoft.Web/serverFarms"
        }

        ManagementSubnet = {
          address_prefixes = ["10.1.6.0/24"]
        }

        DBSubnet = {
          address_prefixes = ["10.1.4.0/24"]
          delegation       = "Microsoft.DBforPostgreSQL/flexibleServers"
        }
      }

      nsgs = {
        AGWSubnet              = "NSG-DEV-AGW"
        ContainerAppsSubnet    = "NSG-DEV-CONTAINERAPPS"
        PrivateEndpointsSubnet = "NSG-DEV-PRIVATE-ENDPOINTS"
        FunctionsSubnet        = "NSG-DEV-FUNCTIONS"
        ManagementSubnet       = "NSG-DEV-MANAGEMENT"
      }

      postgres_server_name = "pgsql-ctmp-dev"

      storage_account_name = "stctmpdev001"

      acr_name = "ctmpdevacr001"

      log_workspace_name = "law-ctmp-dev"

      container_apps_env_name = "cae-ctmp-dev"

      function_app_name = "func-ctmp-dev"

      keyvault_name = "kvctmpdev001"

      app_insights_name = "appi-ctmp-dev"

      action_group_name = "ag-ctmp-dev"

      domain_name = "sneakertail.online"

      frontdoor_profile_name = "afd-ctmp-dev"
    }

    prod = {

      rg_name = "RG-CTMP-PROD"

      vnet_name = "VNET-CTMP-PROD"

      address_space = ["10.2.0.0/16"]

      subnets = {

        AGWSubnet = {
          address_prefixes = ["10.2.1.0/24"]
        }

        ContainerAppsSubnet = {
          address_prefixes = ["10.2.8.0/22"]
          delegation       = "Microsoft.App/environments"
        }

        FunctionsSubnet = {
          address_prefixes = ["10.2.4.0/24"]
          delegation       = "Microsoft.Web/serverFarms"
        }

        PrivateEndpointsSubnet = {
          address_prefixes = ["10.2.5.0/24"]
        }

        ManagementSubnet = {
          address_prefixes = ["10.2.6.0/24"]
        }

        DBSubnet = {
          address_prefixes = ["10.2.7.0/24"]
          delegation       = "Microsoft.DBforPostgreSQL/flexibleServers"
        }
      }

      nsgs = {
        AGWSubnet              = "NSG-PROD-AGW"
        ContainerAppsSubnet    = "NSG-PROD-CONTAINERAPPS"
        FunctionsSubnet        = "NSG-PROD-FUNCTIONS"
        PrivateEndpointsSubnet = "NSG-PROD-PRIVATE-ENDPOINTS"
        ManagementSubnet       = "NSG-PROD-MANAGEMENT"
      }

      postgres_server_name = "pgsql-ctmp-prod"

      storage_account_name = "stctmpprod001"

      acr_name = "ctmpprodacr001"

      log_workspace_name = "law-ctmp-prod"

      container_apps_env_name = "cae-ctmp-prod"

      function_app_name = "func-ctmp-prod"

      keyvault_name = "kvctmpprod001"

      app_insights_name = "appi-ctmp-prod"

      action_group_name = "ag-ctmp-prod"

      domain_name = "sneakertail.online"

      frontdoor_profile_name = "afd-ctmp-prod"
    }
  }
}