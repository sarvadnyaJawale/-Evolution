provider "aws" {
  region = "ap-south-1"
  access_key = "AKIA3ZZIKHCO6CD6HJYY"
  secret_key = "rz3eAu7DbsplQuPVGFcscJ+FbuzgK+hLrCpLb3tL"
}


resource "aws_vpc" "example" {
  cidr_block          = "10.0.0.0/16"
  enable_dns_support  = true
  enable_dns_hostnames = true

  tags = {
    Name = "example-vpc"
  }
}


resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.example.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"  
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}


resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.example.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1b"  
  map_public_ip_on_launch = false

  tags = {
    Name = "private-subnet"
  }
}


resource "aws_launch_template" "example" {
  name          = "example-launch-template"
  image_id      = "ami-03f4878755434977f"  
  instance_type = "t2.micro"
  key_name      = "Kotak.pem"  
  

  user_data = <<-EOF
    #!/bin/bash
    # Install packages/scripts to report load average metrics
    apt-get update && apt-get install -y collectd
    # Configure collectd to send metrics to CloudWatch
    # ...
  EOF
}


resource "aws_autoscaling_group" "example" {
  launch_template {
    id      = aws_launch_template.example.id
    version = "$Latest"  
  }
  vpc_zone_identifier  = [aws_subnet.public.id, aws_subnet.private.id]
  min_size             = 2
  max_size             = 5
  health_check_type    = "EC2"
  # target_group_arns    = ["your_target_group_arn"]  
}


resource "aws_appautoscaling_policy" "scale_out" {
  name               = "scale_out_on_load_average"
  service_namespace  = "ec2"
  scalable_dimension = "ec2:instances"
  resource_id        = "service/autoscaling/AutoScalingGroup:${aws_autoscaling_group.example.name}"
  policy_type        = "StepScaling"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300  # 
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

 

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageLoadAverage"
    }
    target_value = 75.0
  }
}


resource "aws_appautoscaling_policy" "scale_in" {
  name               = "scale_in_on_load_average"
  service_namespace  = "ec2"
  scalable_dimension = "ec2:instances"
  resource_id        = "service/autoscaling/AutoScalingGroup:${aws_autoscaling_group.example.name}"
  policy_type        = "StepScaling"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300  # 5-minute cooldown
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = -1
    }
  }
}


resource "aws_appautoscaling_scheduled_action" "refresh" {
  name = refresh
  service_namespace  = "ec2"
  scalable_dimension = "ec2:instances"
  resource_id        = "service/autoscaling/AutoScalingGroup:${aws_autoscaling_group.example.name}"
  schedule           = "cron(0 12 * * ? *)"  # UTC 12am daily

  scalable_target_action {
    min_capacity       = 0
    max_capacity       = 0
  }
}


resource "aws_cloudwatch_metric_alarm" "example_alarm" {
  alarm_name          = "example-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "LoadAverage"  
  namespace           = "CustomMetrics"  
  period              = 300
  statistic           = "Average"
  threshold           = 75.0
  alarm_actions       = ["arn:aws:sns:ap-south-1:811296503965:metric_alarm"]
}
