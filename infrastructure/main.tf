# Configure AWS Credentials & Region
provider "aws" {
  profile = "${var.profile}"
  shared_credentials_file = "~/.aws/credentials"
  region  = "${var.region}"
  allowed_account_ids = "${var.allowed_account_ids}"
}

# S3 Bucket for storing Elastic Beanstalk task definitions
resource "aws_s3_bucket" "ng_beanstalk_deploys" {
  bucket = "${var.application_name}-deployments"
  force_destroy = true
}

# Elastic Container Repository for Docker images
resource "aws_ecr_repository" "ng_container_repository" {
  name = "${var.application_name}"
}

# Beanstalk instance profile
resource "aws_iam_instance_profile" "ng_beanstalk_ec2" {
  name  = "ng-beanstalk-ec2-user"
  role = "${aws_iam_role.ng_beanstalk_ec2.name}"
}

resource "aws_iam_role" "ng_beanstalk_ec2" {
  name = "ng-beanstalk-ec2-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Beanstalk EC2 Policy
# Overriding because by default Beanstalk does not have a permission to Read ECR
resource "aws_iam_role_policy" "ng_beanstalk_ec2_policy" {
  name = "ng_beanstalk_ec2_policy_with_ECR"
  role = "${aws_iam_role.ng_beanstalk_ec2.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "cloudwatch:PutMetricData",
        "ds:CreateComputer",
        "ds:DescribeDirectories",
        "ec2:DescribeInstanceStatus",
        "logs:*",
        "ssm:*",
        "ec2messages:*",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:DescribeRepositories",
        "ecr:ListImages",
        "ecr:DescribeImages",
        "ecr:BatchGetImage",
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_key_pair" "ssh_key_pair" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_security_group" "allow_ssh_security_group" {
  name = "${var.application_name}_allow_ssh"
  description = "Allow ssh connections on port 22"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["212.78.221.106/32", "109.235.33.64/32"]
  }
}

# Beanstalk Application
resource "aws_elastic_beanstalk_application" "ng_beanstalk_application" {
  name        = "${var.application_name}"
  description = "${var.application_description}"
}

# Beanstalk Environment
resource "aws_elastic_beanstalk_environment" "ng_beanstalk_application_environment" {
  name                = "${var.application_name}-${var.application_environment}"
  application         = "${aws_elastic_beanstalk_application.ng_beanstalk_application.name}"
  solution_stack_name = "${var.esb_solution_stack_name}"
  tier                = "WebServer"

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"

    value = "${var.instance_type}"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"

    value = "${aws_security_group.allow_ssh_security_group.name}"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"

    value = "${aws_key_pair.ssh_key_pair.key_name}"
  }

  # Autoscaling
  setting {
    namespace = "aws:autoscaling:trigger"
    name = "LowerBreachScaleIncrement"
    value = "${var.autoscaling_lower_breach_scale_increment}"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name = "UpperBreachScaleIncrement"
    value = "${var.autoscaling_upper_breach_scale_increment}"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name = "UpperThreshold"
    value = "${var.autoscaling_upper_threshold}"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name = "LowerThreshold"
    value = "${var.autoscaling_LowerThreshold}"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name = "BreachDuration"
    value = "${var.autoscaling_breach_duration}"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name = "MeasureName"
    value = "${var.autoscaling_measure_name}"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name = "EvaluationPeriods"
    value = "${var.autoscaling_evaluation_periods}"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name = "Period"
    value = "${var.autoscaling_period}"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name = "Statistic"
    value = "${var.autoscaling_statistic}"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name = "Unit"
    value = "${var.autoscaling_unit}"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name = "MaxSize"
    value = "${var.autoscaling_max_size}"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name = "MinSize"
    value = "${var.autoscaling_min_size}"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "${aws_iam_instance_profile.ng_beanstalk_ec2.name}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application"
    name      = "Application Healthcheck URL"
    value     = "${var.healthcheck_url}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "DeploymentPolicy"
    value     = "${var.deployment_policy}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "BatchSizeType"
    value     = "${var.batch_size_type}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "BatchSize"
    value     = "${var.batch_size}"
  }

  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "RollingUpdateEnabled"
    value     = "${var.rolling_update_enabled}"
  }

  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "MinInstancesInService"
    value     = "${var.min_instances_in_service}"
  }

  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "RollingUpdateType"
    value     = "${var.rolling_update_type}"
  }

//Custom environment variables
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "CUSTOM_VARIABLE"
    value = "${var.env_custom_variable}"
  }
}

