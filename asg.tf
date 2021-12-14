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
  load_balancers            = [module.elb.elb_id]

  launch_template {
    id      = aws_launch_template.wordpress_launch_template.id
    version = "$Latest"
  }

  # A lifecycle hook provides a specified amount of time (one hour by default) to complete
  # the lifecycle action before the instance transitions to the next state. 
  # autoscaling:EC2_INSTANCE_TERMINATING tells us when the ASG is trying to terminate an instance.
  # heartbeat_timeout = wait state of an instance in seconds
  initial_lifecycle_hook {
    name                 = "graceful_shutdown_asg"
    default_result       = "CONTINUE"
    heartbeat_timeout    = 1800
    lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"

    notification_target_arn = "arn:aws:sns:us-east-1:648826012845:asg-graceful-termination"
    role_arn                = "arn:aws:iam::648826012845:role/asg-sns-role"
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
    LoadBalancer = module.elb.elb_id
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
    LoadBalancer = module.elb.elb_id
  }

}