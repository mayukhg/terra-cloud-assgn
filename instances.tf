#Get Linux AMI ID using SSM Parameter endpoint in us-east-1
data "aws_ssm_parameter" "linuxAmi" {
  #provider = aws.region-master
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}
resource "random_id" "x" {
  byte_length = 4
}

resource "aws_iam_role" "ec2" {
  name = "S3${var.s3bucket}-${random_id.x.dec}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "s3" {
  name = "S3${var.s3bucket}-${random_id.x.dec}"
  role = "${aws_iam_role.ec2.name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetBucketLocation"
            ],
            "Resource": [
                "arn:aws:s3:::${var.s3bucket}",
                "arn:aws:s3:::${var.s3bucket}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:PutObjectAcl",
                "s3:GetObject",
                "s3:GetObjectAcl",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::${var.s3bucket}",
                "arn:aws:s3:::${var.s3bucket}/*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_instance_profile" "ec2" {
  name = "S3${var.s3bucket}-${random_id.x.dec}"
  role = "${aws_iam_role.ec2.name}"
}

#Get Linux AMI ID using SSM Parameter endpoint in us-west-2
data "aws_ssm_parameter" "linuxAmiOregon" {
  #provider = aws.region-worker
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# Create Autolaunch configuration
resource "aws_launch_configuration" "al-tf-web" {
  name          = "al-tf-web"
  instance_type = var.instance-type
  #ami                    = data.aws_ssm_parameter.linuxAmi.value
  image_id        = data.aws_ssm_parameter.linuxAmi.value
  security_groups = ["${aws_security_group.test-sg.id}"]
  #vpc_security_group_ids = [aws_security_group.test-sg.id]
  key_name             = var.key_name
  iam_instance_profile = "${aws_iam_instance_profile.ec2.name}"
  #user_data = "${data.template_file.installnginx.rendered}"
  user_data = "${file("userdata.sh")}"


  /*
  ami                         = data.aws_ssm_parameter.linuxAmi.value
  availability_zone           = var.availability_zones[0]
  instance_type               = var.instance-type
  key_name                    = var.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.test-sg.id]
  subnet_id                   = aws_subnet.public[0].id
  */

  lifecycle {
    create_before_destroy = true
  }

}

# Create AutoScaling group
resource "aws_autoscaling_group" "as-tf-web" {
  name                 = "as-tf-web"
  launch_configuration = "${aws_launch_configuration.al-tf-web.name}"
  min_size             = 1
  max_size             = 2
  desired_capacity     = 2
  target_group_arns    = ["${aws_lb_target_group.tf-tg.arn}"]
  vpc_zone_identifier  = [aws_subnet.public_1[0].id, aws_subnet.public_2[0].id]
  #vpc_zone_identifier  = ["${var.subnet_weba}", "${var.subnet_webb}"]

  lifecycle {
    create_before_destroy = true
  }

  tags = [
    {
      key                 = "CR"
      value               = "SHUTDOWN"
      propagate_at_launch = true
    },
    {
      key                 = "Name"
      value               = "TF-Web"
      propagate_at_launch = true
    },
  ]
}


/*data "template_file" "installnginx" {
  template = "${file("${path.module}/installnginx.tpl")}"
}*/


/*
#Get Linux AMI ID using SSM Parameter endpoint in us-east-1
data "aws_ssm_parameter" "linuxAmi" {
  #provider = aws.region-master
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

#Get Linux AMI ID using SSM Parameter endpoint in us-west-2
data "aws_ssm_parameter" "linuxAmiOregon" {
  #provider = aws.region-worker
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

#Create key-pair for logging into EC2 in us-east-1

resource "aws_key_pair" "master-key" {
  #provider   = aws.region-master
  key_name   = var.key_name
  public_key = file("~/.ssh/id_rsa.pub")
}

#Create and bootstrap EC2 in us-east-1
resource "aws_instance" "asg-instance" {
  #provider                    = aws.region-master
  ami                         = data.aws_ssm_parameter.linuxAmi.value
  availability_zone           = var.availability_zones[0]
  instance_type               = var.instance-type
  key_name                    = var.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.test-sg.id]
  subnet_id                   = aws_subnet.public[0].id
  #subnet_id = aws_subnet.public.id
  provisioner "local-exec" {
    command = <<EOF
aws --profile ${var.profile} ec2 wait instance-status-ok --region ${var.region-master} --instance-ids ${self.id} \
&& ansible-playbook --extra-vars 'passed_in_hosts=tag_Name_${self.tags.Name}' ansible_templates/install_jenkins.yaml
EOF
  }
  tags = {
    Name = "jenkins_master_tf"
  }
  depends_on = [aws_main_route_table_association.set-master-default-rt-assoc]
}*/