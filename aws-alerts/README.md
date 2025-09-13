
# AWS Alerts

1. Create terraform.tfvars.secret file using terraform.tfvars.secret.template
2. Update the file and add you email.


```shell
terraform apply -var-file="terraform.tfvars.secret" -auto-approve
```

```shell
terraform destroy -var-file="terraform.tfvars.secret" -auto-approve
```