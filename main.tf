resource "aws_s3_bucket" "public_snapshots" {
  bucket = "dydx-snapshots-public"
}

# Unlock public access to the bucket
resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.public_snapshots.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "bucket_permissions" {

  # Complete access for the dydxopsdao organization
  statement {
    principals {
      type = "AWS"
      identifiers = [
        "075421299018", # dydxopsdao organization account
      ]
    }

    actions = [
      "s3:*",
    ]

    resources = [
      aws_s3_bucket.public_snapshots.arn,
      "${aws_s3_bucket.public_snapshots.arn}/*",
    ]
  }

  # Write but not delete for selected external accounts
  statement {
    principals {
      type = "AWS"
      identifiers = [
        "637423473456", # KingNodes (point of contact: Jerome)
      ]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject",
      "s3:GetBucketOwnershipControls",
    ]

    resources = [
      aws_s3_bucket.public_snapshots.arn,
      "${aws_s3_bucket.public_snapshots.arn}/*",
    ]
  }

  # Read access for the world
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.public_snapshots.arn,
      "${aws_s3_bucket.public_snapshots.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "bucket_permissions" {
  bucket = aws_s3_bucket.public_snapshots.id
  policy = data.aws_iam_policy_document.bucket_permissions.json
}
