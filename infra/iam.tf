data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ec2" {
  name               = "docmost-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Name    = "docmost-ec2-role"
    Project = "docmost"
  }
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "docmost-ec2-instance-profile"
  role = aws_iam_role.ec2.name
}

data "aws_iam_policy_document" "ec2_parameters" {
  statement {
    effect = "Allow"

    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters"
    ]

    resources = [
      "arn:aws:ssm:eu-north-1:${data.aws_caller_identity.current.account_id}:parameter/docmost/*"
    ]
  }
}

resource "aws_iam_role_policy" "ec2_parameters" {
  name   = "docmost-parameter-read"
  role   = aws_iam_role.ec2.id
  policy = data.aws_iam_policy_document.ec2_parameters.json
}
