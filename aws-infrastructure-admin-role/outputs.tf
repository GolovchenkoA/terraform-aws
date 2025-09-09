
output "infrastructure_admins_switch_role_url" {
  description = "URL to switch to the infrastructure_admins role in the AWS Console"
  value       = "AWS Console switch role url: https://signin.aws.amazon.com/switchrole?roleName=${aws_iam_role.infrastructure_admins.name}&account=${split(":", aws_iam_role.infrastructure_admins.arn)[4]}&displayName=InfraAdmins"
}

output "how_to_assume_infrastructure_admin_role" {
  description = "AWS infrastructure administrator role ARN"
  value = <<EOT
#     You can update your ./aws/config file and add the role like this:

      [profile infra-admin]
      source_profile = default
      role_arn = ${aws_iam_role.infrastructure_admins.arn}
      role_session_name = infra-admin-session-name

#     How to use the profile
      aws s3 ls --profile infra-admin
   EOT
}

# Role
output "infrastructure_admin_role" {
  description = "AWS infrastructure administrator role ARN"
  value = aws_iam_role.infrastructure_admins.arn
}


# Group
# output "infrastructure_admin_group" {
#   description = "AWS infrastructure administrator role ARN"
#   value = aws_iam_group.infrastructure_admins.arn
# }