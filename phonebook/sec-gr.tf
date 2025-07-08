resource "aws_security_group" "instance-sg" {
    name = "WebServerSG"
    vpc_id = data.aws_vpc.default.id
    tags = {
      Name="TF-WEBSERVER-SG"
    }
    ingress {

        from_port = 80
        protocol = "tcp"
        to_port = 80
        description = "SG for web server"
        security_groups = [ aws_security_group.alb-sg.id ]
  
}
ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = [ "0.0.0.0/0" ]
}


egress {
    
    from_port =0
    protocol="-1"
    to_port = 0 
    cidr_blocks = [ "0.0.0.0/0" ]
    
    }

}



resource "aws_security_group" "alb-sg" {

    name = "alb-sg"
    vpc_id = data.aws_vpc.default.id

    ingress {
        from_port = 80
        protocol = "tcp"
        to_port = 80
        description = "sg for alb"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        protocol = "-1"
        to_port = 0
        cidr_blocks = ["0.0.0.0/0"]
    }
  
}
  
resource "aws_security_group" "db-sg" {

    name = "RDS-DB-SG"
    vpc_id = data.aws_vpc.default.id
    tags = {
      Name="DB-SB"
    }
    ingress {
        from_port = 3306
        protocol = "tcp"
        to_port = 3306
        description = "sg for db"
        security_groups = [aws_security_group.instance-sg.id]
    }
    egress {
        from_port = 0
        protocol = "-1"
        to_port = 0
        cidr_blocks = [ "0.0.0.0/0" ]


    }
    
}

  
