# Auto Scaling Group
resource "aws_autoscaling_group" "wp_asg" {

  name                = "wodpress-asg"
  vpc_zone_identifier = ["${module.vpc.public_subnets[0]}",
                         "${module.vpc.public_subnets[1]}",
                         "${module.vpc.public_subnets[2]}" 
                        ]

  max_size                  = 3
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = false
  target_group_arns = ["${aws_lb_target_group.wp_alb_tg.arn}"]

  launch_template {
    id      = aws_launch_template.wordpress_launch_template.id
    version = "$Latest"
  }


  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  tag {
    key                 = "Name"
    value               = "wordpress-asg"
    propagate_at_launch = true
  }

}

resource "aws_autoscaling_policy" "wp_scale_out" {
  name                   = "wordpress-app-scale-out"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.wp_asg.id
}

resource "aws_autoscaling_policy" "wp_scale_in" {
  name                   = "wordpress-app-scale-in"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.wp_asg.id
}

resource "aws_cloudwatch_metric_alarm" "wp_scale_out_alarm" {
  alarm_name          = "CPU usage is above 40%"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "40"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_autoscaling_policy.wp_scale_out.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.wp_asg.id
  }
}

resource "aws_cloudwatch_metric_alarm" "wp_scale_in_alarm" {
  alarm_name          = "CPU usage is below 40%"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "40"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_autoscaling_policy.wp_scale_in.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.wp_asg.id
  }

}