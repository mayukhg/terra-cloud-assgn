

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

# Create Autolaunch configuration
resource "aws_launch_configuration" "al-tf-web" {
  name            = "al-tf-web"
  instance_type   = var.instance-type
  image_id        = data.aws_ssm_parameter.linuxAmi.value
  security_groups = ["${aws_security_group.test-sg.id}"]
  #vpc_security_group_ids = [aws_security_group.test-sg.id]
  key_name             = var.key_name
  user_data            = "${file("userdata.sh")}"

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