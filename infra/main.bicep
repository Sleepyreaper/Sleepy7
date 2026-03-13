targetScope = 'subscription'

@description('Deployment environment name (e.g. dev, staging, prod)')
param environment string

@description('Azure region for all regional resources')
param location string = 'eastus'

@description('Project name used for resource naming')
param projectName string = 'sleepy7'

@description('Owner tag')
param owner string = 'team-sleepy7'

@description('Cost center tag')
param costCenter string = 'games'

@description('Optional unique suffix to avoid naming collisions')
param suffix string = uniqueString(subscription().id, environment, projectName)

@description('Repository for Function App source deployment metadata')
param repositoryUrl string = 'https://github.com/sleepyreaper/sleepy7'

@description('Azure AD B2C tenant issuer URL, e.g. https://<tenant>.b2clogin.com/<tenant>.onmicrosoft.com/v2.0/')
param b2cIssuer string = 'https://example.b2clogin.com/example.onmicrosoft.com/v2.0/'

@description('Expected audience (API App ID URI or client ID)')
param b2cAudience string = 'api://sleepy7-api'

var rgName = '${projectName}-${environment}-rg'
var tags = {
  environment: environment
  project: projectName
  owner: owner
  costCenter: costCenter
}

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: rgName
  location: location
  tags: tags
}

resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  scope: rg
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
    publicNetworkAccess: 'Enabled'
  }
}

module appInsights './modules/appInsights.bicep' = {
  name: 'appInsightsDeploy'
  scope: rg
  params: {
    location: location
    projectName: projectName
    environment: environment
    suffix: suffix
    tags: tags
  }
}

module keyVault './modules/keyVault.bicep' = {
  name: 'keyVaultDeploy'
  scope: rg
  params: {
    location: location
    projectName: projectName
    environment: environment
    suffix: suffix
    tags: tags
  }
}

module appConfig './modules/appConfig.bicep' = {
  name: 'appConfigDeploy'
  scope: rg
  params: {
    location: location
    projectName: projectName
    environment: environment
    suffix: suffix
    tags: tags
  }
}

module functions './modules/functionApp.bicep' = {
  name: 'functionsDeploy'
  scope: rg
  params: {
    location: location
    projectName: projectName
    environment: environment
    suffix: suffix
    tags: tags
    appInsightsConnectionStringSecretUri: keyVault.outputs.appInsightsConnectionStringSecretUri
    cosmosEndpoint: 'https://placeholder.documents.azure.com:443/'
    cosmosDbName: 'sleepy7'
    scoresContainerName: 'scores'
    configContainerName: 'config'
    appConfigEndpoint: appConfig.outputs.endpoint
    storageAccountResourceId: storage.id
    repositoryUrl: repositoryUrl
    b2cIssuer: b2cIssuer
    b2cAudience: b2cAudience
  }
}

module cosmos './modules/cosmos.bicep' = {
  name: 'cosmosDeploy'
  scope: rg
  params: {
    location: location
    projectName: projectName
    environment: environment
    suffix: suffix
    tags: tags
    functionPrincipalId: functions.outputs.principalId
  }
}

resource kvSetAppInsightsConnectionString 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  scope: rg
  name: '${keyVault.outputs.name}/appInsightsConnectionString'
  properties: {
    value: appInsights.outputs.connectionString
  }
  dependsOn: [
    keyVault
    appInsights
  ]
}

resource kvAccessForFunction 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: rg
  name: guid(keyVault.outputs.id, functions.outputs.principalId, 'kv-secrets-user')
  properties: {
    principalId: functions.outputs.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')
    principalType: 'ServicePrincipal'
  }
  dependsOn: [
    functions
    keyVault
  ]
}

resource functionAppSettingsUpdate 'Microsoft.Web/sites/config@2023-12-01' = {
  scope: rg
  name: '${functions.outputs.functionAppName}/appsettings'
  properties: {
    COSMOS_ENDPOINT: cosmos.outputs.endpoint
    COSMOS_DATABASE: cosmos.outputs.databaseName
    COSMOS_CONTAINER_SCORES: cosmos.outputs.scoresContainerName
    COSMOS_CONTAINER_CONFIG: cosmos.outputs.configContainerName
    APPLICATIONINSIGHTS_CONNECTION_STRING: '@Microsoft.KeyVault(SecretUri=${keyVault.outputs.appInsightsConnectionStringSecretUri})'
  }
  dependsOn: [
    cosmos
    functions
    kvSetAppInsightsConnectionString
    kvAccessForFunction
  ]
}

output resourceGroupName string = rgName
output functionAppName string = functions.outputs.functionAppName
output functionAppPrincipalId string = functions.outputs.principalId
output cosmosAccountName string = cosmos.outputs.accountName
output appConfigName string = appConfig.outputs.name
output storageAccountName string = storage.name
output keyVaultName string = keyVault.outputs.name