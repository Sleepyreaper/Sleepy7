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

resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: toLower(substring(replace('${projectName}${environment}st${suffix}', '-', ''), 0, 24))
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false
    accessTier: 'Hot'
  }
}

output name string = storage.name
output resourceId string = storage.id