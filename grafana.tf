module "managed_grafana" {
  source  = "terraform-aws-modules/managed-service-grafana/aws"
  version = "1.10.0"

  name                      = "ymkgrafana"
  associate_license         = false
  description               = "manged grafana to fetch managed prometheus metrics"
  account_access_type       = "CURRENT_ACCOUNT"
  authentication_providers  = ["AWS_SSO"]
  permission_type           = "SERVICE_MANAGED"
  data_sources              = ["CLOUDWATCH", "PROMETHEUS", "XRAY"]
  notification_destinations = ["SNS"]
  stack_set_name            = "ymkgrafana"

  configuration = jsonencode({
    unifiedAlerting = {
      enabled = true
    }
  })

  grafana_version = "10.4"


  # Workspace IAM role
  create_iam_role                = true
  iam_role_name                  = "ymk-managed-grafana"
  use_iam_role_name_prefix       = true
  iam_role_description           = "manged grafana to fetch managed prometheus metrics"
  iam_role_path                  = "/grafana/"
  iam_role_force_detach_policies = true
  iam_role_max_session_duration  = 7200
  iam_role_tags                  = local.tags

  tags = local.tags
}


# resource "aws_grafana_workspace" "example" {
#   name        = "eks-monitoring-grafana"
#   description = "Grafana for monitoring EKS cluster"
#   account_access_type = "CURRENT_ACCOUNT"
#   authentication_providers = ["AWS_SSO"]

#   permission_type = "SERVICE_MANAGED"
#   tags = {
#     Environment = "dev"
#   }
# }


