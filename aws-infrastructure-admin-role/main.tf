provider "aws" {
  region = "us-east-1"
  access_key = var.access_key != "" ? var.access_key : null
  secret_key = var.secret_key != "" ? var.secret_key : null
}

# Get current AWS account ID for constructing ARNs
data "aws_caller_identity" "current" {}

# There are 2 ways how to provide permissions to users:
# 1. Use groups and roles.
# 2. Use assume roles



# ################## Way 1. Adding users to a group ###################################
#  Should be used when users should have permissions all the time (!!! it's not secure, especially for admins)
# 1. A new group created
# 2. Policy added to the group
# 3. Users added to the group

# IAM Group
# resource "aws_iam_group" "infrastructure_admins" {
#   name = "InfrastructureAdmins"
# }
#
# // Adding policies to the group
# resource "aws_iam_group_policy_attachment" "administrator_policy_attach" {
#   group      = aws_iam_group.infrastructure_admins.name
#   policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
# }
#
#
# # Adding users to the group
# resource "aws_iam_group_membership" "infrastructure_admins_membership" {
#   name = "infrastructure-admins-membership"
#   group = aws_iam_group.infrastructure_admins.name
#   users = var.admin_users
# }

##########################################################


# ################## Way 2. AWS Assume Role ###################################

# IAM Role that the group members can assume
resource "aws_iam_role" "infrastructure_admins" {
  name = "aws-infrastructure-admin-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "sts:AssumeRole",
        Principal = {
          AWS = [
            for user in var.admin_users :
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${user}"
          ]
        }
      }
    ]
  })

  tags = {
    RoleType = "InfrastructureAdmin"
  }
}

# # Attach AdministratorAccess policy to the role
resource "aws_iam_role_policy_attachment" "administrator_policy_attach" {
  role       = aws_iam_role.infrastructure_admins.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
