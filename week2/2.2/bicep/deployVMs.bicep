

param location string = resourceGroup().location
param environment string = 'Dev'
param osDiskType string = 'Standard_LRS'
param adminUsername string
@secure()
param adminPassword string

@allowed([
  '12.04.5-LTS'
  '14.04.5-LTS'
  '16.04.0-LTS'
  '18.04-LTS'
])
param ubuntuOSVersion string = '18.04-LTS'


var numberOfVMs = 2
var vmNameFormat = 'vmubuntu{0}'
var osDiskNameFormat = 'osdisk-{0}-01'
var networkInterfaceName = 'nic-{0}-01'

module networkModule 'deployNetwork.bicep' = {
  name: 'networkDeploy'
  params:{
    location: location
    environment: environment
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2020-11-01' = [for i in range(0, numberOfVMs): {
  name: format(networkInterfaceName, format(vmNameFormat, padLeft(i, 2, '0')))
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: networkModule.outputs.subnets[i].id
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}]

resource virtualmachines 'Microsoft.Compute/virtualMachines@2020-12-01' = [for i in range(0, numberOfVMs): {
  name: format(vmNameFormat, padLeft(i, 2, '0'))
  location: location
  properties:{
    hardwareProfile:{
      vmSize:'Standard_B1s'
    }
    storageProfile:{
      osDisk:{
        name: format(osDiskNameFormat, format(vmNameFormat, padLeft(i, 2, '0')))
        createOption:'FromImage'
        managedDisk:{
          storageAccountType: osDiskType
        }
      }
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: ubuntuOSVersion
        version: 'latest'
      }
    }
    networkProfile:{
      networkInterfaces:[
        {
          id: nic[i].id
        }
      ]
    }
    osProfile:{
      computerName: format(vmNameFormat, padLeft(i, 2, '0'))
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
  }
}]

output adminUsername string = adminUsername
