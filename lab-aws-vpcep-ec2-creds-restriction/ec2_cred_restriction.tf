resource "aws_iam_role_policy" "deny_use_of_ec2_credentials_outside_instance_policy" {
  count = var.restrict_ec2_instances_credentials ? 1 : 0
  
  name = "deny-use-of-ec2-credentials-outside-instance-policy"
  role = aws_iam_role.s3_list_buckets_role.name 

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Deny",
            "Action": "*",
            "Resource": "*",
            "Condition": {
                    "StringNotEquals": {
                        "aws:ec2InstanceSourceVPC": "$${aws:SourceVpc}"
                    },
                    "Null": {
                        "ec2:SourceInstanceARN": "false"
                    },
                    "BoolIfExists": {
                        "aws:ViaAWSService": "false"
                    }
            }
        },
        {
            "Effect": "Deny",
            "Action": "*",
            "Resource": "*",
            "Condition": {
                    "StringNotEquals": {
                        "aws:ec2InstanceSourcePrivateIPv4": "$${aws:VpcSourceIp}"
                    },
                    "Null": {
                        "ec2:SourceInstanceARN": "false"
                    },
                    "BoolIfExists": {
                        "aws:ViaAWSService": "false"
                    }
            }
        }
    ]
  })
}

