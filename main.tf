terraform {
  

   backend "s3" {
    bucket         = "demovpc1-bucket"
    key            = "terraform/terra4.state"
    region         = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"


  }


resource "aws_instance" "demo1-server" {
    ami = "ami-0230bd60aa48260c6"
    instance_type = "t2.micro"
    key_name = "practice"
  subnet_id = aws_subnet.demo1_subnet.id
  vpc_security_group_ids = [ aws_security_group.demo1-vpc-sg.id]
}
 
# VPC
resource "aws_vpc" "demo1-vpc" {
    cidr_block = "10.10.0.0/16"
    
      
    }
  


#sub
resource "aws_subnet" "demo1_subnet" {
    vpc_id = aws_vpc.demo1-vpc.id
    cidr_block = "10.10.1.0/24"

    tags = {
      Name = "demo1_subnet"
    }
  
}

#igw 
resource "aws_internet_gateway" "demo1-igw" {
    vpc_id = aws_vpc.demo1-vpc.id
    tags = {
      Name = "demo1-igw"
    }
}

#rt
resource "aws_route_table" "demo1-rt" {
    vpc_id = aws_vpc.demo1-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.demo1-igw.id
    }
    tags  =  {
        Name = "demo1-rt"
    }
}

# Associate subnet with routetable 

resource "aws_route_table_association" "demo1-rt_association" {
    subnet_id = aws_subnet.demo1_subnet.id
    route_table_id = aws_route_table.demo1-rt.id
}
  

  
resource "aws_security_group" "demo1-vpc-sg" {
  name        = "demo1-vpc-sg"
  vpc_id      = aws_vpc.demo1-vpc.id

  ingress {
    
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}