targetScope = 'subscription'

resource rg 'Microsoft.Resources/resourceGroups@2020-06-01' = {
    location: 'eastus2'
    name: 'rg'
}

module networkScaffold './network.bicep' = {
    name: 'network-scaffold'
    scope: resourceGroup(rg.name)
    params: {
        bastionName: 'bastion'
        vnetName: 'vnet'
    }
}