targetScope = 'subscription'

param resourceGroupName string
param location string

param username string
param windowsVMPassword string {
    secure: true
}

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
    }
}

module dataWin1 '../00-scaffold/vm-windows-win2019.bicep' = {
    name: 'data-win1'
    scope: resourceGroup(rg.name)
    params: {
        enableAcceleratedNetworking: true
        vmName: 'data1-win2019'
        vmSize: 'Standard_DS2_v2'
        subnetId: reference('networkScaffold').outputs.dataServerSubnetId.value
        zone: '1'
        username: username
        password: windowsVMPassword
    }
}