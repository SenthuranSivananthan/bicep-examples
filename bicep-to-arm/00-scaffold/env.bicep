targetScope = 'subscription'

param resourceGroupName string
param location string

param username string
param linuxVMPublicKey string {
  secure: true
}

param windowsVMPassword string {
    secure: true
}

resource rg 'Microsoft.Resources/resourceGroups@2020-06-01' = {
    location: location
    name: resourceGroupName
}

module networkScaffold './network.bicep' = {
    name: 'networkScaffold'
    scope: resourceGroup(rg.name)
    params: {
        bastionName: 'bastion'

        vnetName: 'vnet'
        vnetAddressPrefix: '20.0.0.0/16'

        bastionSubnetAddressPrefix: '20.0.1.0/27'
        
        appServerSubnetName: 'AppServers'
        appServerAddressPrefix: '20.0.2.0/24'

        dataServerSubnetName: 'DataServers'
        dataServerAddressPrefix: '20.0.3.0/24'

        netAppSubnetName: 'NetAppFiles'
        netAppAddressPrefix: '20.0.4.0/24'
    }
}

module appServerLinux1 './vm-linux-ubuntu18.bicep' = {
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

module dataWin1 './vm-windows-win2019.bicep' = {
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