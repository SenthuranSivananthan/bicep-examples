param location string

module stg1 './02-rg-scope-new-storage-account.bicep' = {
  name: 'stg1'
  params: {
    storageNamePrefix: 'stg1'
    location: location
  }
}

module stg2 './02-rg-scope-new-storage-account.bicep' = {
  name: 'stg2'
  params: {
    storageNamePrefix: 'stg2'
    location: location
  }
}