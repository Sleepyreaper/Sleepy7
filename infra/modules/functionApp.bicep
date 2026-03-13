@description('Azure region')
param location string

@description('Project name')
param projectName string

@description('Environment')
param environment string

@description('Name suffix')
param suffix string

@description('Resource tags')
param tags object

@description('App Insights connection string secret URI')
param appInsightsConnectionStringSecretUri string

@description('Cosmos endpoint')
param cosmosEndpoint string

@description('Cosmos DB name')
param cosmosDbName string

@description('Cosmos scores container')
param scoresContainerName string

@description('Cosmos config container')
param configContainerName string

@description('App Config endpoint')
param appConfigEndpoint string

@description('Storage account resource ID')
param storageAccountResourceId string

@description('Repository URL')
param repositoryUrl string

@description('Azure AD B2C issuer URL')
param b2cIssuer string

@description('Azure AD B2C audience')
param b2cAudience string

resource plan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: '${projectName}-${environment}-plan-${suffix}'
  location: location
  tags: tags
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  kind: 'functionapp'
}

resource functionApp 'Microsoft.Web/sites@2023-12-01' = {
  name: '${projectName}-${environment}-func-${suffix}'
  location: location
  tags: union(tags, {
    repository: repositoryUrl
  })
  kind: 'functionapp,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    keyVaultReferenceIdentity: 'SystemAssigned'
    serverFarmId: plan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'Node|20'
      minTlsVersion: '1.2'
      ftpsState: 'Disabled'
      appSettings: [
        {
          name: 'AzureWebJobsStorage__accountName'
          value: last(split(storageAccountResourceId, '/'))
        }
        {
          name: 'AzureWebJobsStorage__credential'
          value: 'managedidentity'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'node'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: '@Microsoft.KeyVault(SecretUri=${appInsightsConnectionStringSecretUri})'
        }
        {
          name: 'COSMOS_ENDPOINT'
          value: cosmosEndpoint
        }
        {
          name: 'COSMOS_DATABASE'
          value: cosmosDbName
        }
        {
          name: 'COSMOS_CONTAINER_SCORES'
          value: scoresContainerName
        }
        {
          name: 'COSMOS_CONTAINER_CONFIG'
          value: configContainerName
        }
        {
          name: 'APP_CONFIG_ENDPOINT'
          value: appConfigEndpoint
        }
        {
          name: 'B2C_ISSUER'
          value: b2cIssuer
        }
        {
          name: 'B2C_AUDIENCE'
          value: b2cAudience
        }
        {
          name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
          value: 'true'
        }
        {
          name: 'ENABLE_ORYX_BUILD'
          value: 'true'
        }
      ]
    }
  }
}

output functionAppName string = functionApp.name
output principalId string = functionApp.identity.principalId