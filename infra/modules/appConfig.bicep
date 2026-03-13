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

resource appConfig 'Microsoft.AppConfiguration/configurationStores@2024-05-01' = {
  name: '${projectName}-${environment}-appcfg-${suffix}'
  location: location
  tags: tags
  sku: {
    name: 'standard'
  }
  properties: {
    disableLocalAuth: true
    publicNetworkAccess: 'Enabled'
    softDeleteRetentionInDays: 7
    enablePurgeProtection: false
  }
}

output endpoint string = appConfig.properties.endpoint
output name string = appConfig.name