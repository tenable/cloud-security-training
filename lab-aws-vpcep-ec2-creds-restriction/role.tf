resource "aws_iam_role" "s3_list_buckets_role" {
  name = "s3-list-buckets-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "s3_list_buckets_policy" {
  name = "s3-list-buckets-policy"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListAllMyBuckets"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_list_buckets_role_policy_attachment" {
  policy_arn = aws_iam_policy.s3_list_buckets_policy.arn
  role       = aws_iam_role.s3_list_buckets_role.name
} 

resource "aws_iam_instance_profile" "instance_profile_list_all_buckets" {
  name = "instance_profile_list_all_buckets"
  role = aws_iam_role.s3_list_buckets_role.name
}