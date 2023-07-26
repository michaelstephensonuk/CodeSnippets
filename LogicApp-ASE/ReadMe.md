In thi folder we will have the sample terraform solution for building a logic app AIS solution running on an App Service Environment

For more info refer to this video

https://www.youtube.com/watch?v=-FOMUzutg1M

Also refer to this playlist for more about Logic Apps with ASE

https://www.youtube.com/watch?v=EbgwfEvxQ2w&list=PLa-4Z1GMFicDunPRDySZnSNu6Js29i9ez


# Notes for running terraform in VS Code

cd .
az login 
az account set --subscription "[Your sub id]"
terraform init
terraform validate
terraform refresh -var-file="local.tfvars"
terraform plan -var-file="local.tfvars"
terraform apply -var-file="local.tfvars"
