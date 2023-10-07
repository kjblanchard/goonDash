resource "aws_s3_bucket" "supergoon_dash_bucket" {
  bucket = "supergoon-dash-external-site"
  tags = {
    Name = "Supergoon Dash External Site Bucket"
  }
}
resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.supergoon_dash_bucket.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_iam_user" "supergoon_dash_user" {
  name = "supergoon-dash-uploader"
}

resource "aws_s3_bucket_acl" "b_acl" {
  bucket = aws_s3_bucket.supergoon_dash_bucket.id
  depends_on = [ aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership ]
  acl    = "private"
}

resource "aws_iam_policy" "pipeline_access_policy" {
  name        = "supergoon_dash_s3_upload_policy"
  description = "Policy for adding items to the supergoon dash bucket."

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = ["s3:PutObject", "s3:ListBucket"],
      Resource = [
        aws_s3_bucket.supergoon_dash_bucket.arn,
        "${aws_s3_bucket.supergoon_dash_bucket.arn}/*",
      ],
    }],
  })
}

resource "aws_iam_user_policy_attachment" "supergoon_dash_attachment" {
  policy_arn = aws_iam_policy.pipeline_access_policy.arn
  user       = aws_iam_user.supergoon_dash_user.name
}
