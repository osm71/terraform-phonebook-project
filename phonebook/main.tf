resource "aws_alb_target_group" "app-tg" {
    name = "App-tg"
    port = 80
    protocol = "HTTP"
    vpc_id = data.aws_vpc.default.id
    target_type = "instance"

    health_check {
        path = "/"
      healthy_threshold= 2
      unhealthy_threshold = 3
      interval = 15
      timeout = 10
    }
  
}

resource "aws_alb" "app-alb" {

    name = "app-alb"
    ip_address_type = "ipv4"
    internal = false
    load_balancer_type = "application"
    security_groups = [aws_security_group.alb-sg.id]
    subnets = data.aws_subnets.default.ids
}

resource "aws_alb_listener" "app-alb-listener" {
load_balancer_arn = aws_alb.app-alb.arn
port = 80
protocol = "HTTP"
default_action {
  target_group_arn = aws_alb_target_group.app-tg.arn
  type = "forward"
}
  
}

resource "aws_autoscaling_group" "app-asg" {

    max_size = 3
    min_size = 1
    desired_capacity = 2
    name = "app-asg"
    health_check_grace_period = 300
    health_check_type = "ELB"
    target_group_arns = [aws_alb_target_group.app-tg.arn]
    vpc_zone_identifier = aws_alb.app-alb.subnets
    launch_template {
        id = aws_launch_template.app-launch-tamplate.id
        version = aws_launch_template.app-launch-tamplate.latest_version
      
    }
  
}

resource "aws_launch_template" "app-launch-tamplate" {  
    name = "app-lt"
    image_id = data.aws_ami.aws-ami-2023.id
    vpc_security_group_ids = [aws_security_group.instance-sg.id]
    instance_type = "t2.micro"
    key_name = var.key-name
    user_data = base64encode(templatefile("userdata.sh", {db-endpoint=aws_db_instance.app-db.address,user-data-git-token= var.git-token, user-data-git-name=var.git-name }))
    tags = {
      Name="Web Server od APP"
    }
  
}


resource "aws_db_instance" "app-db" {
    instance_class = "db.t3.micro"
    allocated_storage = 20
    vpc_security_group_ids = [ aws_security_group.db-sg.id ]
    allow_major_version_upgrade = false
    auto_minor_version_upgrade = true
    engine = "mysql"
    engine_version = "8.0.35"
    identifier = "app-db"
    db_name = "phonebook"
    username = "admin"
    password = "Oliver_1"
    backup_retention_period = 0
    monitoring_interval = 0
    multi_az = false
    port = 3306
    publicly_accessible = false
    skip_final_snapshot = true


  
}

resource "aws_route53_record" "app-53record" {
    type="A"
    name="phonebook.${var.hosted-name}"
    zone_id=data.aws_route53_zone.selected.zone_id
    alias {
      evaluate_target_health = true
      name = aws_alb.app-alb.dns_name
      zone_id = aws_alb.app-alb.zone_id
    }
  
}

