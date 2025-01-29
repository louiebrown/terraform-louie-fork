# terraform-louie
This repository is a space for any Terraform exercises completed as part of the 2025 Platforms Academy.

## Required Steps

1. Create a new resoource group to hold the resouces for this activity:
`az group create --name <RESOURCE_GROUP_NAME> --location <LOCATION>`

2. Create a new storage account to enable terraform access to your azure resources:
`az storage account create --name <STORAGE_ACCOUNT_NAME> --resource-group <RESOURCE_GROUP_NAME> --location <LOCATION> --sku Standard_LRS --encryption-services blob`

3. Create a new storage container to hold and track the terraform state files:
`az storage container create --name terraform-state --account-name <STORAGE_ACCOUNT_NAME>`

4. Retrieve the Storage Account Key for the Terraform backend
`az storage account keys list --account-name <STORAGE_ACCOUNT_NAME> --query "[0].value" --output tsv`

- Ensure to include a `secrets.tfvars` file in your local repository to hold any variables. This will be ignored and will **not** be published to the repository.

## Running Terraform

```bash
terraform init

terraform plan

terraform apply

terraform apply -var-file "secrets.tfvars" # Optional

terraform destroy
```