{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::driven-data-bucket-mykhailo-task5",
                "arn:aws:s3:::driven-data-bucket-mykhailo-task5/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "glue:*"
        ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
        ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:*"
        ],
            "Resource": [
                "*"
            ]
        }
    ]
}