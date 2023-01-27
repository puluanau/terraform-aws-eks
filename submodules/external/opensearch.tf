resource "random_password" "opensearch_password" {
  length  = 16
  special = true
}

resource "aws_opensearch_domain" "this" {
  domain_name    = var.deploy_id
  engine_version = var.opensearch.engine_version

  cluster_config {
    instance_type          = var.opensearch.instance_type
    zone_awareness_enabled = true

    zone_awareness_config {
      availability_zone_count = length(var.subnet_ids)
    }

    dedicated_master_enabled = false
    instance_count           = length(var.subnet_ids)

    warm_enabled = false

    cold_storage_options {
      enabled = false
    }
  }

  # auto_tune_options {
  #   desired_state = "ENABLED"
  #   maintenance_schedule {
  #     start_at = ""
  #     duration {
  #       value =
  #       unit =
  #     }
  #     cron_expression_for_recurrence = ""
  #   }
  # }

  vpc_options {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.external.id]
  }

  advanced_security_options {
    enabled                        = true
    anonymous_auth_enabled         = false
    internal_user_database_enabled = true
    master_user_options {
      master_user_name     = var.opensearch.username
      master_user_password = resource.random_password.opensearch_password.result
    }
  }

  # snapshot_options {
  #   automated_snapshot_start_hour = ???
  # }

  encrypt_at_rest {
    enabled = true
    # kms_key_id = aws_kms_key.example.arn
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  node_to_node_encryption {
    enabled = true
  }

  ebs_options {
    ebs_enabled = true
    volume_type = "gp3"
    volume_size = var.opensearch.volume_size
  }

  # log_publishing_options {
  #   cloudwatch_log_group_arn = aws_cloudwatch_log_group.example.arn
  #   log_type                 = "INDEX_SLOW_LOGS"
  # }

  depends_on = [aws_iam_service_linked_role.this]
}


# resource "aws_cloudwatch_log_group" "example" {
#   name = "example"
# }

resource "aws_iam_service_linked_role" "this" {
  aws_service_name = "opensearchservice.amazonaws.com"
}


# resource "aws_cloudwatch_log_resource_policy" "example" {
#   policy_name = "example"
#
#   policy_document = <<CONFIG
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "es.amazonaws.com"
#       },
#       "Action": [
#         "logs:PutLogEvents",
#         "logs:PutLogEventsBatch",
#         "logs:CreateLogStream"
#       ],
#       "Resource": "arn:aws:logs:*"
#     }
#   ]
# }
# CONFIG
# }

resource "aws_opensearch_domain_policy" "this" {
  domain_name = aws_opensearch_domain.this.domain_name

  access_policies = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "*"
        ]
      },
      "Action": [
        "es:ESHttp*"
      ],
      "Resource": "${aws_opensearch_domain.this.arn}/*"
    }
  ]
}
POLICY
}
