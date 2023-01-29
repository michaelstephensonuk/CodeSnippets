cd .
az login 
az account set --subscription "92357fca-2391-4501-b98a-6a93589ba4c9"
terraform init
terraform validate
terraform apply

terraform refresh -var-file=Local.tfvars
terraform plan -var-file=Local.tfvars
terraform apply -var-file=Local.tfvars 
pause


# Powershell for the Logic App Script

Connect-AzAccount
Set-AzContext -Subscription "92357fca-2391-4501-b98a-6a93589ba4c9"
