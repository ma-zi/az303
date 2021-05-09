#!/bin/bash
RG=rg-xfiles-westeurope

az group create --name $RG --location westeurope
az deployment group create \
  --name xfilesdeployment \
  --resource-group $RG \
  --template-file deployVMs.json \
  --parameters deployVMsParameters.json