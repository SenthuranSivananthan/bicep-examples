param netAppAccountName string

module networkScaffold '../00-scaffold/network.bicep' = {
    name: 'networkScaffold'
    params: {
        bastionName: 'bastion'
        vnetName: 'vnet'
    }
}

resource netappAccount 'Microsoft.NetApp/netAppAccounts@2020-06-01' = {
    name: netAppAccountName
    location: resourceGroup().location
}

var netAppCapacityPoolName = 'pool1'
resource netappCapacityPool 'Microsoft.NetApp/netAppAccounts/capacityPools@2020-06-01' = {
    name: '${netappAccount.name}/${netAppCapacityPoolName}'
    location: resourceGroup().location
    properties: {
        qosType: 'Auto'
        serviceLevel: 'Standard'
        size: '4398046511104' // 4 TiB
    }
}

var netAppVolumeName = 'volume1'
resource netAppVolume 'Microsoft.NetApp/netAppAccounts/capacityPools/volumes@2020-06-01' = {
    name: '${netappCapacityPool.name}/${netAppVolumeName}'
    location: resourceGroup().location
    properties: {
        subnetId: networkScaffold.outputs.netAppSubnetId
        creationToken: netAppVolumeName
        usageThreshold: '107374182400' // 100 GiB
        protocolTypes:[
            'NFSv3'
        ]
    }
}