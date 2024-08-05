# Terraform Infrastructure Setup

This repository contains Terraform code to set up a basic web server infrastructure on AWS, including a Virtual Private Cloud (VPC), public subnets, an Application Load Balancer (ALB), an Auto Scaling Group (ASG) with EC2 instances, and security groups with rules for HTTP and HTTPS traffic.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads) installed on your local machine.
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate AWS credentials.
- [Make](https://www.gnu.org/software/make/) installed (for using the Makefile).

## Directory Structure

- `main.tf`: Contains the main Terraform configuration including VPC, subnets, security groups, load balancer, and auto-scaling group.
- `locals.tf`: Defines local values used in the Terraform configuration.
- `variables.tf`: Defines input variables for the Terraform configuration.
- `terraform.tfvars`: Provides default values for the input variables.
- `versions.tf`: Specifies the required Terraform and provider versions.
- `Makefile`: Includes shortcuts for Terraform commands.
- `backend.tf`: Include config for the terraform remote state.
- `output.tf`: Blocks for the required outputs.

## Usage

1. **Clone the Repository**

   ```sh
   git clone https://github.com/your-repository.git
   cd your-repository
   ```

2. **Initialize Terraform and Review Changes**

    Initialize the Terraform working directory. downloads the necessary provider plugins and sets up the backend.
    Note: On the first run, the `terraform` block in `backend.tf` should be commented. (Refer to the explanations in the file)

   ```sh
   make plan
   ```
   
3. **Apply Changes**

    Apply the changes required to reach the desired state of the configuration. This command will create or update the resources defined in your `local` Terraform files.

    ```sh
    make apply
    ```

4. **Destroy Infrastructure (Optional)**

    To remove all the resources created by Terraform, use the destroy target from the Makefile.

    ```sh
    make destroy
    ```

### **Makefile Targets**
**plan:** Runs terraform plan to show changes required by the configuration.
**apply:** Runs terraform apply to apply changes required by the configuration.
**destroy:** Runs terraform destroy to remove all resources managed by the configuration.

### **Security Groups**
**Load Balancer Security Group:** Allows inbound HTTP (port 80) and HTTPS (port 443) traffic from the whole internet.
**Pending Improvment:** Web Server Security Group should be configured to accept HTTP/HTTPs only from the LoadBalancer.

### **Notes**
Instead of using account credentials (access keys), it is suggested to implement AWS SSO and Create and Configure IAM Roles for AWS SSO.

