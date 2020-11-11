targetScope = 'subscription'

param username string
param sshPublicKey string

resource rg 'Microsoft.Resources/resourceGroups@2020-06-01' = {
    location: 'eastus2'
    name: 'rg2'
}

module networkScaffold './network.bicep' = {
    name: 'networkScaffold'
    scope: resourceGroup(rg.name)
    params: {
        bastionName: 'bastion'
        vnetName: 'vnet'
        appServerSubnetName: 'AppServers'
        dataServerSubnetName: 'DataServers'
        netAppSubnetName: 'NetAppFiles'
    }
}

module appServerLinux1 './linux-vm-ubuntu18.bicep' = {
    name: 'app1-linux'
    scope: resourceGroup(rg.name)
    params: {
        enableAcceleratedNetworking: true
        vmName: 'app1-linux'
        vmSize: 'Standard_DS2_v2'
        subnetId: reference('networkScaffold').outputs.appServerSubnetId.value
        zone: '1'
        username: username
        sshPublicKey: sshPublicKey
    }
}