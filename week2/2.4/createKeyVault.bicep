param environment string = 'Dev'
param tenantId string = subscription().tenantId
param location string = resourceGroup().location
param objectId string

param secretName string
@secure()
param secretValue string


var tags = {
  'Env': environment
}

resource keyvault 'Microsoft.KeyVault/vaults@2021-04-01-preview' = {
  name: 'kvxfiles01'
  tags: tags
  location: location
  properties: {
    tenantId: tenantId
    enabledForTemplateDeployment: true
    sku:{
      family: 'A'
      name: 'standard'
    }
    accessPolicies:[
      {
        objectId: objectId
        tenantId: tenantId
        permissions:{
          secrets: [
            'get'
            'list'
          ]
        }
      }
    ]
  }

}

resource secret 'Microsoft.KeyVault/vaults/secrets@2018-02-14' = {
  name: '${keyvault.name}/${secretName}'
  properties: {
    value: secretValue
  }
}
