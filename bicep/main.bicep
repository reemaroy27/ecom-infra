@description('Environment short name, e.g., dev | uat | prod')
param env string

@description('Azure location, e.g., westeurope, eastus, centralindia')
param location string

@description('Resource prefix, e.g., ecom')
param prefix string

// -------------------- STORAGE ACCOUNT (ADLS Gen2) --------------------
var stgName = toLower('${prefix}${env}stg')

resource stg 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: stgName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    isHnsEnabled: true
  }
}

// Layer containers
resource raw 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = {
  name: '${stg.name}/default/raw'
}
resource bronze 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = {
  name: '${stg.name}/default/bronze'
}
resource silver 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = {
  name: '${stg.name}/default/silver'
}
resource gold 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = {
  name: '${stg.name}/default/gold'
}

// -------------------- DATABRICKS WORKSPACE --------------------

var dbxName = toLower('${prefix}-${env}-dbx')
var dbxManagedRg = '${prefix}-${env}-dbx-mrg'

resource dbx 'Microsoft.Databricks/workspaces@2023-02-01' = {
  name: dbxName
  location: location
  sku: {
    name: 'standard'
  }
  properties: {
    managedResourceGroupId: subscriptionResourceId('Microsoft.Resources/resourceGroups', dbxManagedRg)
  }
}

// -------------------- ADF INSTANCE --------------------
var adfName = toLower('${prefix}-${env}-adf')

resource adf 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: adfName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {}
}

// -------------------- MANAGED IDENTITY (ACCESS CONNECTOR) --------------------
var miName = toLower('${prefix}-${env}-access-mi')

resource uami 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: miName
  location: location
}

// -------------------- OUTPUTS --------------------
output storageAccount string = stg.name
output databricksWorkspace string = dbx.name
output dataFactory string = adf.name
output managedIdentity string = uami.name
