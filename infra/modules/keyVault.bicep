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

resource kv 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: '${projectName}-${environment}-kv-${suffix}'
  location: location
  tags: tags
  properties: {
    tenantId: tenant().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    accessPolicies: []      // we use RBAC
    enableRbacAuthorization: true
    enabledForTemplateDeployment: true
    publicNetworkAccess: 'Disabled'     // 🔐 lock it down
    softDeleteRetentionInDays: 90
    enablePurgeProtection: true         // 🔐 ransom-ware antidote
  }
}

output id string = kv.id
output name string = kv.name
output appInsightsConnectionStringSecretUri string = 'https://${kv.name}.vault.azure.net/secrets/appInsightsConnectionString'