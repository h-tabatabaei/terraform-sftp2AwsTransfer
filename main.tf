locals {
  bucket_name   = "sftp-transfer-msd-${random_id.this.dec}"
  accout_number = "725049844389"
}

#Retrieve the list of AZs in the current AWS region
data "aws_availability_zones" "available" {}
data "aws_region" "current" {}

resource "random_id" "this" {
  byte_length = 5
}

resource "aws_s3_bucket" "sftp_bucket" {
  bucket = local.bucket_name
  tags = {
    Name      = local.bucket_name
    Region    = data.aws_region.current.name
    Terraform = "true"
  }
}

resource "aws_iam_policy" "userAccessS3" {
  name        = "userAccess_S3"
  path        = "/"
  description = "User Access Policy to s3"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowListigOfUserFolder",
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        "Resource" : [
          "arn:aws:s3:::${local.bucket_name}"
        ]
      },
      {
        "Sid" : "HomeDirObjectAccess",
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:GetObjectVersion",
          "s3:DeleteObjectVersion"
        ],
        "Resource" : [
          "arn:aws:s3:::${local.bucket_name}",
          "arn:aws:s3:::${local.bucket_name}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "sftp_to_s3_iamRole" {
  name = "sftp_to_s3_iamRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "transfer.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name      = "sftp_to_s3_iamRole"
    Region    = data.aws_region.current.name
    Terraform = "true"
  }
}

resource "aws_iam_role_policy_attachment" "sftp_to_s3_iamRole-attach" {
  role       = aws_iam_role.sftp_to_s3_iamRole.name
  policy_arn = aws_iam_policy.userAccessS3.arn
}

resource "aws_transfer_server" "sftp_srv" {
  tags = {
    Name      = "sftp_srv"
    Region    = data.aws_region.current.name
    Terraform = "true"
  }
}

resource "tls_private_key" "ssh_pkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh_kp" {
  key_name   = "ssh_key"
  public_key = tls_private_key.ssh_pkey.public_key_openssh
}
resource "local_file" "private_key_pem" {
  content  = tls_private_key.ssh_pkey.private_key_pem
  filename = "MyAWSKey.pem"
}

resource "aws_transfer_user" "transfer_user" {
  server_id = aws_transfer_server.sftp_srv.id
  user_name = "msdtbt"
  role      = aws_iam_role.sftp_to_s3_iamRole.arn

  home_directory      = "/${aws_s3_bucket.sftp_bucket.id}"
}

resource "aws_transfer_ssh_key" "transfer_user_public_key" {
  server_id = aws_transfer_server.sftp_srv.id
  user_name = aws_transfer_user.transfer_user.user_name
  body      = aws_key_pair.ssh_kp.public_key
}
