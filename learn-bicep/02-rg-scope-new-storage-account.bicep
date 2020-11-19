param location string
param storageNamePrefix string

var uniqueSuffix = uniqueString(resourceGroup().id)

resource myStorage 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: '${storageNamePrefix}${uniqueSuffix}'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

output storageId string = myStorage.id