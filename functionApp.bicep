@secure()
param appInsightsConnectionStringSecretId string

...
{
  name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
  value: '@Microsoft.KeyVault(SecretUri=${appInsightsConnectionStringSecretId})'
}