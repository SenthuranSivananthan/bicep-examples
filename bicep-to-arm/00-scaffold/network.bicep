param vnetName string
param bastionName string

var bastionSubnetName = 'AzureBastionSubnet' // must be this name
param appServerSubnetName string = 'AppServers'
param dataServerSubnetName string = 'DataServers'
param netAppSubnetName string = 'NetAppFiles'

resource nsgBastionServer 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
    name: 'nsg-bastion'
    location: resourceGroup().location
    properties: {
        securityRules: [
            {
                name: 'AllowHttpsInbound'
                properties: {
                    priority: 120
                    direction: 'Inbound'
                    access: 'Allow'
                    protocol: 'Tcp'
                    sourceAddressPrefix: 'Internet'
                    sourcePortRange: '*'
                    destinationAddressPrefix: '*'
                    destinationPortRange: '443'
                }
            }
            {
                name: 'AllowGatewayManagerInbound'
                properties: {
                    priority: 130
                    direction: 'Inbound'
                    access: 'Allow'
                    protocol: 'Tcp'
                    sourceAddressPrefix: 'GatewayManager'
                    sourcePortRange: '*'
                    destinationAddressPrefix: '*'
                    destinationPortRange: '443'
                }
            }
            {
                name: 'AllowSshRdpOutbound'
                properties: {
                    priority: 100
                    direction: 'Outbound'
                    access: 'Allow'
                    protocol: '*'
                    sourceAddressPrefix: '*'
                    sourcePortRange: '*'
                    destinationAddressPrefix: 'VirtualNetwork'
                    destinationPortRanges: [
                        '22'
                        '3389'
                    ]
                }
            }
            {
                name: 'AllowAzureCloudOutbound'
                properties: {
                    priority: 110
                    direction: 'Outbound'
                    access: 'Allow'
                    protocol: 'Tcp'
                    sourceAddressPrefix: '*'
                    sourcePortRange: '*'
                    destinationAddressPrefix: 'AzureCloud'
                    destinationPortRange: '443'
                }
            }
        ]
    }
}


resource nsgAppServer 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
    name: 'nsg-appserver'
    location: resourceGroup().location
}

resource nsgDataServer 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
    name: 'nsg-dataserver'
    location: resourceGroup().location
}

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
    location: resourceGroup().location
    name: vnetName
    properties: {
        addressSpace: {
            addressPrefixes: [
                '10.0.0.0/16'
            ]
        }
        subnets: [
            {
                name: bastionSubnetName
                properties: {
                    addressPrefix: '10.0.1.0/27'
                    networkSecurityGroup: {
                        id: nsgBastionServer.id
                    }
                }
            }
            {
                name: appServerSubnetName
                properties: {
                    addressPrefix: '10.0.2.0/24'
                    networkSecurityGroup: {
                        id: nsgAppServer.id
                    }
                }
            }
            {
                name: dataServerSubnetName
                properties: {
                    addressPrefix: '10.0.3.0/24'
                    networkSecurityGroup: {
                        id: nsgDataServer.id
                    }
                }
            }
            {
                name: netAppSubnetName
                properties: {
                    addressPrefix: '10.0.4.0/24'
                    delegations: [
                        {
                            name: 'Microsoft.Netapp.volumes'
                            properties: {
                                serviceName: 'Microsoft.Netapp/volumes'
                            }
                        }
                    ]
                }
            }
        ]
    }
}

resource bastionPublicIP 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
    location: resourceGroup().location
    name: '${bastionName}-publicip'
    sku: {
        name: 'Standard'
    }
    properties: {
        publicIPAddressVersion: 'IPv4'
        publicIPAllocationMethod: 'Static'
    }
}

resource bastion 'Microsoft.Network/bastionHosts@2020-06-01' = {
    location: resourceGroup().location
    name: bastionName
    properties: {
        dnsName: uniqueString(resourceGroup().id)
        ipConfigurations: [
            {
                name: 'IpConf'
                properties: {
                    subnet: {
                        id: '${vnet.id}/subnets/${bastionSubnetName}'
                    }
                    publicIPAddress: {
                        id: bastionPublicIP.id
                    }
                }
            }
        ]
    }
}

output appServerSubnetId string = '${vnet.id}/subnets/${appServerSubnetName}'
output dataServerSubnetId string = '${vnet.id}/subnets/${appServerSubnetName}'
output netAppSubnetId string = '${vnet.id}/subnets/${netAppSubnetName}'