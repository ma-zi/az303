#!/bin/bash
RG=rg-keyvault-westeurope

az group create --name $RG --location westeurope
az deployment group create \
  --name keyvaultdeployment \
  --resource-group $RG \
  --template-file createKeyVault.bicep \
  --parameters createKeyVaultParameters.json