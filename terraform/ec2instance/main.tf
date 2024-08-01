data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


resource "aws_security_group" "main" {
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins_security_group"
  }
}


resource "aws_instance" "jenkins_demo" {
  for_each   = toset(var.machines)
  ami           = data.aws_ami.ubuntu.id  
  instance_type = "t3.medium"
  security_groups = [aws_security_group.main.name]
  user_data = file("files/app_host.sh")
  tags = {
    Name = "${each.key}"
  }
}



resource "aws_instance" "app_host" {
  ami           = data.aws_ami.ubuntu.id  
  instance_type = "t3.medium"
  security_groups = [aws_security_group.main.name]
  user_data = file("files/userdata.sh")
  
}



variable "machines" {
    default = ["jenkins"]
}

# Output SSH connection strings
output "ssh_connect_strings" {
  value = [
    for idx in var.machines : 
    "ssh jenkins@${aws_instance.jenkins_demo[idx].public_ip}"
  ]
}

output "jenkins_url" {
  value = [
    for idx in var.machines : 
    "https://${aws_instance.jenkins_demo[idx].public_ip}:8080"
    ]
}


output "ssh_connect_strings_app_host" {
  value ="ssh jenkins@${aws_instance.app_host.public_ip}"
}