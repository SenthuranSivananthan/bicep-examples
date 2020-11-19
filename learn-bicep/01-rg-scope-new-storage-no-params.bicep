resource myStorage 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: 'senthuran123'
  location: 'eastus'
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}