var location = 'eastus'
var vnetName = 'vnet'
var bastionName = 'bastion'

resource nsgBastionServer 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
    name: 'nsg-bastion'
    location: location
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
    location: location
}

resource nsgDataServer 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
    name: 'nsg-dataserver'
    location: location
}

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
    location: location
    name: vnetName
    properties: {
        addressSpace: {
            addressPrefixes: [
                '10.0.0.0/16'
            ]
        }
        subnets: [
            {
                name: 'AzureBastionSubnet'
                properties: {
                    addressPrefix: '10.0.1.0/27'
                    networkSecurityGroup: {
                        id: nsgBastionServer.id
                    }
                }
            }
            {
                name: 'AppServers'
                properties: {
                    addressPrefix: '10.0.2.0/24'
                    networkSecurityGroup: {
                        id: nsgAppServer.id
                    }
                }
            }
            {
                name: 'DataServers'
                properties: {
                    addressPrefix: '10.0.3.0/24'
                    networkSecurityGroup: {
                        id: nsgDataServer.id
                    }
                }
            }
            {
                name: 'NetAppFiles'
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
    location: location
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
    location: location
    name: bastionName
    properties: {
        dnsName: uniqueString(resourceGroup().id)
        ipConfigurations: [
            {
                name: 'IpConf'
                properties: {
                    subnet: {
                        id: '${vnet.id}/subnets/AzureBastionSubnet'
                    }
                    publicIPAddress: {
                        id: bastionPublicIP.id
                    }
                }
            }
        ]
    }
}