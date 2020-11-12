targetScope = 'subscription'

param resourceGroupName string
param location string

param username string
param linuxVMPublicKey string {
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

module appServerLinux1 '../00-scaffold/vm-linux-ubuntu18.bicep' = {
    name: 'app1-linux'
    scope: resourceGroup(rg.name)
    params: {
        enableAcceleratedNetworking: true
        vmName: 'app1-linux'
        vmSize: 'Standard_DS2_v2'
        subnetId: reference('networkScaffold').outputs.appServerSubnetId.value
        zone: '1'
        username: username
        sshPublicKey: linuxVMPublicKey
    }
}
