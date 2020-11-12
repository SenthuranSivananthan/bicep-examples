targetScope = 'subscription'

param resourceGroupName string
param location string

resource rg 'Microsoft.Resources/resourceGroups@2020-06-01' = {
    location: location
    name: resourceGroupName
}

module networkScaffold '../00-scaffold/network.bicep' = {
    name: 'networkScaffold'
    scope: resourceGroup(rg.name)
    params: {
        bastionName: 'bastion'

        vnetName: 'vnet'
        vnetAddressPrefix: '10.0.0.0/16'

        bastionSubnetAddressPrefix: '10.0.1.0/27'
        
        appServerSubnetName: 'AppServers'
        appServerAddressPrefix: '10.0.2.0/24'

        dataServerSubnetName: 'DataServers'
        dataServerAddressPrefix: '10.0.3.0/24'

        netAppSubnetName: 'NetAppFiles'
        netAppAddressPrefix: '10.0.4.0/24'
    }
}
