param storageId string
param uamiPrincipalId string
param adfPrincipalId string

// Built‑in roles
var storageBlobDataContributor = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'

// ----- UAMI → Storage -----
resource uamiStorage 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageId, uamiPrincipalId, storageBlobDataContributor)
  scope: storageId
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataContributor)
    principalId: uamiPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// ----- ADF MSI → Storage -----
resource adfStorage 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageId, adfPrincipalId, storageBlobDataContributor)
  scope: storageId
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataContributor)
    principalId: adfPrincipalId
    principalType: 'ServicePrincipal'
  }
}
