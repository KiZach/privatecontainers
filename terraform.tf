terraform {
    required_version = ">=1.3.7"

    backend "local" {
        path = "./terraform/terraform.tfstate"
    }
}