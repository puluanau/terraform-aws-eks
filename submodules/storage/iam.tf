data "aws_iam_policy_document" "s3" {
  statement {
    effect    = "Allow"
    resources = [for b in local.s3_buckets : b.arn if b.is_eks_node_bucket]

    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:ListBucketMultipartUploads",
    ]
  }

  statement {
    sid    = ""
    effect = "Allow"

    resources = [for b in local.s3_buckets : "${b.arn}/*" if b.is_eks_node_bucket]

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:ListMultipartUploadParts",
      "s3:AbortMultipartUpload",
    ]
  }
}

data "aws_iam_policy_document" "s3_irsa" {
  count = var.irsa.enabled ? 1 : 0
  statement {
    effect    = "Allow"
    resources = [for b in local.s3_buckets : b.arn if !b.is_eks_node_bucket]

    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:ListBucketMultipartUploads",
    ]
  }

  statement {
    sid    = ""
    effect = "Allow"

    resources = [for b in local.s3_buckets : "${b.arn}/*" if !b.is_eks_node_bucket]

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:ListMultipartUploadParts",
      "s3:AbortMultipartUpload",
    ]
  }
}

resource "aws_iam_policy" "s3" {
  name   = "${var.deploy_id}-S3"
  path   = "/"
  policy = data.aws_iam_policy_document.s3.json
}

resource "aws_iam_policy" "s3_irsa" {
  count  = var.irsa.enabled ? 1 : 0
  name   = "${var.deploy_id}-S3-irsa"
  path   = "/"
  policy = data.aws_iam_policy_document.s3_irsa[0].json
}

data "aws_iam_policy_document" "ecr" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions   = ["ecr:GetAuthorizationToken"]
  }

  statement {
    effect = "Allow"

    resources = [for k, repo in aws_ecr_repository.this : repo.arn]

    actions = [
      # Pull
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      # Push
      "ecr:CompleteLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:InitiateLayerUpload",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage"
    ]
  }
}

resource "aws_iam_policy" "ecr" {
  name   = "${var.deploy_id}-ECR"
  path   = "/"
  policy = data.aws_iam_policy_document.ecr.json
}
