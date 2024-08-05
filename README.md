If you want to test this project you can follow this guide. Note that this guide creates resources that cost money so dont forget to destroy the resources as soon as you are done testing to avoid paying unnecessary costs.




1. https://aws.amazon.com/resources/create-account/
2. Create an IAM user and generate access keys https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html
3. Use the access keys to authenticate with AWS https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration
4. Initialize the Terraform repository and providers:
```
terraform init
```
1. Check the plan: 
```
terraform plan
```
1. Execute the plan:
```
terraform apply
```

You can then use the public IP returned by Terraform as an output to your browser and you should see the web server up and running:

```http://<public_ip>```

7. Destroy the resources(important to avoid extra costs):
```
terraform destroy
```
