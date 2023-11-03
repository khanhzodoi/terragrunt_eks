# Terragrunt EKS (EBS && Cluster Auto Scaler) + RDS Project
**Brief Description**: This project provides infrastructure setup instructions for deploying an Amazon EKS (Elastic Kubernetes Service) cluster with Elastic Block Storage (EBS) and Cluster Auto Scaler support, along with an Amazon RDS (Relational Database Service) instance.

**License**: This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Introduction
The project focuses on streamlining the setup and management of your Kubernetes cluster and database instances on the AWS cloud. It includes instructions for configuring AWS credentials, installing Terragrunt, creating the EKS cluster, configuring kubectl for Kubernetes access, examining default Kubernetes roles and permissions, exploring cluster add-ons, and running test cases.

The provided documentation enables users to efficiently set up and manage their infrastructure, making it a valuable resource for anyone looking to deploy EKS clusters and RDS instances on AWS.

**Contact**: If you want to collaborate with me , please reach out via email at khanhpham.100398@gmail.com, phone number: (+84) 0328807722
**Found an Issue?** If you come across any issues or have suggestions for improvement, please don't hesitate to create a new issue. I value your feedback and use it to make this project better for everyone.

[Create a New Issue](link_to_your_issue_tracker)

## Branches
- **main**: Use the `main` branch for stable releases and production-ready code.
- **develop**: If you want to contribute or test the latest features and changes, use the `develop` branch.

## Notices
- **In Development**: This project will be further developed to include additional features, such as a bastion host and AWS Elasticache. In additon, more k8s-manifests will be created to enhance k8s security like network policy.
- **Local Statefile**: With this first release, Terraform state files are stored locally. There are plans to develop `./scripts/generate-s3-dynamodb.sh` for DynamoDB and S3 to store files remotely.

## How to get started on Linux
0. Please setup the vagrant environment or make the environment will necessary bin files before continuing next steps
```bash
# This vagrant will startup a virtual machine => Then, install necessary binaries in scripts/bootstrap.sh, please take a look at it if you want.
vagrant up
vagrant ssh

# Install Terragrunt by the following link: https://terragrunt.gruntwork.io
```

1. Setup IAM credential for AWS CLI && terragrunt
```bash
# Setup aws profile
aws configure --profile <profile_name>
```

```conf
# Config the credential properly in the infrastructure-live-v2/terragrunt.hcl file
provider "aws" {
    region = "<region_name>"
    shared_config_files = ["<path_to_aws_cli_config_file>"]
    shared_credentials_files = ["<path_to_aws_cli_credential_file>"]
    profile = "<profile_name>"
}
```
2. Create EKS using Terragrunt on **dev** enviroment
- Go to terragrunt folder
```bash
cd infrastructure-live-v2/dev
terragrunt run-all validate
terragrunt run-all apply
```
- We can **clone infrastructure-live-v2/dev** folder and rename it to **staging** for example and change infrastructure-live-v2/staging/env.hcl content to create a new environment to work with

3. Use AWS CLI to config kubectl context
```bash
# Updated your local kubeconfig
aws eks --region <region_name> update-kubeconfig --name <eks-cluster-name> --profile <profile-name>

# Get context and detele it when neccessary
kubectl config get-contexts
kubectl config delete-context <context-name>

# Select context when neccessary
kubectl config use-context <context-name>
```

4. Show default eks created K8S roles and users
```bash
# Show ClusterRoles
kubectl get clusterroles | grep eks

# Show any role specification
kubectl describe clusterrole <cluster-role-name>

# Show ClusterRoleBindings
kubectl get clusterrolebinding | grep eks

# Show any ClusterRoleBindings specification
kubectl describe clusterrolebinding <cluster-role-name>
```

5. Show cluster add-ons
```bash
aws eks list-addons --cluster-name <cluster-name> --profile <profile-name>
aws eks describe-addon --cluster-name  <cluster-name> --addon-name <name-of-addon>
```

6. Do some test-cases in **k8s-manifests** folder