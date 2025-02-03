#!/bin/bash

# chmod +x

# Prompt user to login to Azure
echo "Logging in to Azure..."
az login

# Define variables for resource group and storage account
RESOURCE_GROUP="louie-terraform-rg"
STORAGE_ACCOUNT="louieterraformsa"  # Adding timestamp for uniqueness
LOCATION="UKSouth"
CONTAINER_NAME="terraform-state"

# Create a resource group
echo "Creating resource group: $RESOURCE_GROUP in location: $LOCATION"
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create a storage account
echo "Creating storage account: $STORAGE_ACCOUNT"
az storage account create \
    --name $STORAGE_ACCOUNT \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --sku Standard_LRS \
    --kind StorageV2

# Display information about the created resources
echo "Resource group and storage account created successfully!"
echo "Resource Group: $RESOURCE_GROUP"
echo "Storage Account: $STORAGE_ACCOUNT"

sleep 10

# Get the storage account key
STORAGE_ACCOUNT_KEY=$(az storage account keys list --account-name $STORAGE_ACCOUNT --query "[0].value" --output tsv)
echo "Storage Key retrieved sucessfully: $STORAGE_ACCOUNT_KEY"

sleep 5

# Create a storage container
echo "Creating storage account: $CONTAINER_NAME"
az storage container create \
    --name $CONTAINER_NAME \
    --account-name $STORAGE_ACCOUNT \
    --account-key $STORAGE_ACCOUNT_KEY
