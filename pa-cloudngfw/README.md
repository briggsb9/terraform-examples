# Terraform Palo Alto Cloud NGFW Deployment

Creates resources in Azure to deploy a Palo Alto Cloud Next-Generation Firewall (NGFW). The NGFW can be deployed with or without Panorama management based on the provided variables

## Prerequisites

Before you begin, ensure you have:

- Azure subscription
- Terraform installed locally
- Azure CLI installed and authenticated

## Usage

1. Clone this repository to your local machine:

    ```bash
    git clone <repository_url>
    ```

2. Navigate to the directory containing the Terraform configuration files:

    ```bash
    cd <repository_directory>
    ```

3. Initialize the Terraform configuration:

    ```bash
    terraform init
    ```

4. Adjust the `variables.tfvars` file according to your environment. Here's an example:

    ```hcl
    location                 = "uksouth"
    resource_prefix          = "demo"
    resource_suffix          = "01"
    subnet_address_prefix_trust  = ["10.0.1.0/24"]
    subnet_address_prefix_untrust = ["10.0.2.0/24"]
    enable_panorama          = true
    panorama_base64_config   = "<base64_encoded_panorama_config>"
    ```

5. Review the Terraform plan to ensure it matches your expectations:

    ```bash
    terraform plan -var-file=variables.tfvars
    ```

6. Apply the Terraform configuration to create the resources:

    ```bash
    terraform apply -var-file=variables.tfvars
    ```

## Resources Created

- Azure Resource Group
- Azure Public IP Address
- Azure Network Security Group
- Azure Virtual Network
- Azure Subnets (Trust and Untrust)
- Palo Alto Local Rule Stack (if enable_panorama is false)
- Palo Alto Local Rule Stack Rule (if enable_panorama is false)
- Palo Alto Next-Generation Firewall (NGFW) Virtual Network

## Customization

You can customize the deployment by adjusting variables in the `variables.tfvars` file. For example, you can change the location, resource naming conventions, subnet
