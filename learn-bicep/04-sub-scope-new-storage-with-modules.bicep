targetScope = 'subscription'

param location string
param rgName string = 'learn-bicep'

resource rg 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: rgName
  location: location
}

module stg1 './02-rg-scope-new-storage-account.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'stg1'
  params: {
    storageNamePrefix: 'stg1'
    location: location
  }
}

module stg2 './02-rg-scope-new-storage-account.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'stg2'
  params: {
    storageNamePrefix: 'stg2'
    location: location
  }
}

output rgId string = rg.id