
resource "aws_vpc" "Terraform-VPC" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  tags = {
    Name = "Terraform-VPC"
  }
}
resource "aws_subnet" "public-subnet-1" {
  vpc_id                  = aws_vpc.Terraform-VPC.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "ap-south-1a"
  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public-subnet-2" {
  vpc_id                  = aws_vpc.Terraform-VPC.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "ap-south-1b"
  tags = {
    Name = "public-subnet-2"
  }
}
resource "aws_internet_gateway" "IG" {
  vpc_id = aws_vpc.Terraform-VPC.id
  tags = {
    Name = "IG"
  }
}
resource "aws_route_table" "Public_s-rt" {
  vpc_id = aws_vpc.Terraform-VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IG.id
  }
  tags = {
    "Name" = "Route_table"
  }
}

// Creating route association for public subnet 
resource "aws_route_table_association" "Public-1-a" {
  subnet_id      = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.Public_s-rt.id
}

resource "aws_route_table_association" "Public-2-a" {
  subnet_id      = aws_subnet.public-subnet-2.id
  route_table_id = aws_route_table.Public_s-rt.id

}

// Creating security group 

resource "aws_security_group" "Terraform-Security" {
  name        = "Terraform-Security"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.Terraform-VPC.id



  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Terraform-Security"
  }
}
// Creating Keypair for instances 
resource "aws_key_pair" "Terraform-key" {
  key_name   = "Terraform-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDp8BMBF9mfruwObVyN0ciodZA4PhuO8IFI5XvcoAXtSvHKQvxVjG3UD70/VYZOaFkyQGRxJ7SqTDhN8aM/VvHMtAaWRGu/T8kE7mXXsHBkhsLe+FyGtXG+Log4W+DSdtiqgKT8JZdl5IwqnIR3UfN803Jv9stLM92HPJYt4T5nOy8iKO+C5EHHZ1OWH4ByoQwP9ISAf7ZPTbR0wqYcEJOYHe6I8q+FaMHtbyG4ZO8nbXDjQ4oIPHKMQY+LOCpjezQY8i586OezJw04JhmzkQn6oQn9DZHZrgPsj+Wf/TQM4ULQj5n+AkMNrhTng68d2Er0LmcWHZdIJRIJh9sDpU9MGcRZTI/9Wwc4lhBuIOtNeUvOZXocv6iPb1NZQnYHHOXWy4XXES1emSy7f4h4aOw0Y3C4pHqe5uMrbbqJxRzyGcW13TY7eETkgxD2X0viyVVsr11Lv6gohnmkFbbTDhL3nBRCuHag7QY2aLX6P4dac0kyks/oYbnwCtpv+xgUOks= amit@amit14"


}


// Creating aws Instances using Terraform 

resource "aws_instance" "Public-inst-01" {
  ami                    = "ami-074dc0a6f6c764218"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public-subnet-1.id
  key_name               = aws_key_pair.Terraform-key.id
  vpc_security_group_ids = ["${aws_security_group.Terraform-Security.id}"]
  tags = {
    "Name" = "Public-inst-01"
  }
}

resource "aws_instance" "Public-inst-02" {
  ami                    = "ami-074dc0a6f6c764218"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public-subnet-2.id
  key_name               = aws_key_pair.Terraform-key.id
  vpc_security_group_ids = ["${aws_security_group.Terraform-Security.id}"]

  tags = {
    "Name" = "Public-inst-02"

  }
}



