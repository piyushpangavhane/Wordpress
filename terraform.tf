terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "remote" {
    organization = "pangavhane"

    workspaces {
      name = "Kite_Production"
    }
  }

  # backend "local" {
  #   path = "terraform.tfstate"
  # }
  required_version = ">=1.3.0"

}
