// 
//      /  snet 01 (nsg) - ubuntu 01
//  vnet 
//      \  snet 02 (nsg) - ubuntu 02
//
param location string = resourceGroup().location
param environment string = 'Dev'

var tags = {
  'Env': environment
}
var vnetName = 'vnet-${location}-01'
var snetName = 'snet-{0}-{1}'


resource nsg 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
  name: 'nsg-weballow-01'
  location: location
  tags: tags
  properties: {
    securityRules:[
      {
        name: 'AllowWebTraffic'
        properties: {
          direction: 'Inbound'
          protocol: '*'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '443'
          access: 'Allow' 
          priority: 1000
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: vnetName
  location: location
  tags: tags
  properties:{
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets:[
      {
        name: format(snetName, 'web', '01')
        properties:{
          addressPrefix: '10.0.0.0/24'
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
      {
        name: format(snetName, 'mail', '01')
        properties:{
          addressPrefix: '10.0.1.0/24'
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }
}

output subnets array = vnet.properties.subnets
