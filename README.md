# privatecontainers

Sample to deploy Terraform Azure private container apps behind Azure Web Application Firewall.

Container information can be found here:
https://github.com/fescobar/allure-docker-service

Running two Allure containers one with the UI and one with the API

After deployment the frontend UI can be accessed only using the public ip of the application gateway and is protected by the WAF policies.

See the solution.png for resource overview.

# To deploy

## AZ Install
winget install -e --id Microsoft.AzureCLI

## Subscription ID 

Update with correct subscription id in the root main.tf file.

## Run code
az Login
.\terraform.exe init
.\terraform.exe plan
