using '../main.bicep'

param environment = 'staging'
param location = 'eastus'
param projectName = 'sleepy7'
param owner = 'marge'
param costCenter = 'games'
param b2cIssuer = 'https://example.b2clogin.com/example.onmicrosoft.com/v2.0/'
param b2cAudience = 'api://sleepy7-api'