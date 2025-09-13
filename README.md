# How to


## aws-infrastructure-admin-role
It's an optional step.  
Use this project to :
- create `aws-infrastructure-admin-role` that can be used later in your `~/.aws/config`  
- add users which allowed to assume the role. 

Open `aws-infrastructure-admin-role/terraform.tfvars` and update the `admin_users` list.  

Your current aws credentials will be used for creating the role in AWS.  
You can set custom credentials with appropriate permissions, if it's needed:
1. Open `aws-infrastructure-admin-role/terraform.tfvars`
2. Set `access_key` and `secret_key`

```shell
cd ./aws-infrastructure-admin-role
terraform init
```

```shell
terraform plan
```

```shell
terraform apply
```

# The "infrastructure" project

```shell
cd ./infrastructure/
```

```shell
terraform init
terraform apply
```