remote_state {
  backend = "local"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    path = "${path_relative_to_include()}/terraform.tfstate"
  }
}


generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"

  contents = <<EOF
provider "aws" {
    region = "ap-southeast-1"
    shared_config_files = ["/home/vagrant/.aws/config"]
    shared_credentials_files = ["/home/vagrant/.aws/credentials"]
    profile = "khanhp-iam"
}
EOF
}