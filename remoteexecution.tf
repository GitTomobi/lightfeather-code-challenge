#VPC
resource "aws_vpc" "codeVPC" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "Code challenge VPC"
  }
}

# Public subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.codeVPC.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1a"

  tags = {
    Name = "Code-Public Subnet"
  }
}

# Private subnet
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.codeVPC.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Code-Private Subnet"
  }
}

#Internet gateway
resource "aws_internet_gateway" "code-igw" {
  vpc_id = aws_vpc.codeVPC.id
  tags = {
    Name = "code-igw"
  }
}

#Elastic IP for NAT
resource "aws_eip" "code-eip" {
  vpc = true
}

#Nat Gateway
resource "aws_nat_gateway" "code-nat" {
  allocation_id = aws_eip.code-eip.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "CodeChallenge-NAT"
  }

  # To ensure proper ordering, add Internet Gateway as dependency
  depends_on = [aws_internet_gateway.code-igw]
}

# Public Route table
resource "aws_route_table" "code-public-RT" {
  vpc_id = aws_vpc.codeVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.code-igw.id
  }

  tags = {
    Name = "Code-Public-RT"
  }
}

#Associate Public Route table
resource "aws_route_table_association" "code-public-subnet-1" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.code-public-RT.id
}

#Private Route table
resource "aws_route_table" "code-private-RT" {
  vpc_id = aws_vpc.codeVPC.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.code-nat.id
  }

  tags = {
    Name = "Code-Private-RT"
  }
}

#Associate Private Route table
resource "aws_route_table_association" "code-private-subnet-1" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.code-private-RT.id
}

# Security Group
resource "aws_security_group" "dynamicSg" {
  vpc_id      = aws_vpc.codeVPC.id
  name        = "Terraform-CodeChallenge-SG"
  description = "CodeChallenge Security group made from Terraform"

  dynamic "ingress" {
    for_each = var.sgPorts 
    iterator = port
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  dynamic "egress" {
    for_each = var.sgPorts 
    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = local.commonTags
}

#EC2 Instance
resource "aws_instance" "frontEnd" {
  ami           = "ami-09d3b3274b6c5d4aa" 
  instance_type = "t2.micro"

  subnet_id = aws_subnet.public.id

  key_name               = "Best-KP"
  vpc_security_group_ids = [aws_security_group.dynamicSg.id]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("../../Key Pairs/Best-KP.pem") // private key should be located outside of project folder.
    host        = self.public_ip
  }
  
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y gcc-c++ make",
      "curl -sL https://rpm.nodesource.com/setup_16.x | sudo -E bash",
      "sudo yum install -y nodejs",
      "sudo npm install -g npm@9.1.1",
      "sudo yum install -y git",
      "sudo git clone https://github.com/GitTomobi/devops-code-challenge.git",
      "sudo npm ci --prefix devops-code-challenge/backend/",
      "sudo npm ci --prefix devops-code-challenge/frontend/",
      "sudo npm audit fix --force",
      "sudo npm install -g npm@9.1.1",
      "echo module.exports = {CORS_ORIGIN: \"'http://${self.public_ip}:3000'\"} | sudo tee devops-code-challenge/backend/config.js",
      "echo export const API_URL = \"'http://${self.public_ip}:8080/'\" | sudo tee devops-code-challenge/frontend/src/config.js",
      "echo export default API_URL | sudo tee -a devops-code-challenge/frontend/src/config.js"
    ]
       
  }

  tags = {
    "Name" = "TerraformWebserver-FrontEnd"
  }

}

locals {
  //project_name = "TerraformWebserver"
  envPrefix    = var.isTest == true ? "Dev" : "Prod"

  commonTags = {
    Owner   = "DevOps Team"
    Service = "Backend"
  }
}