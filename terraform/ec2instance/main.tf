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

  tags = {
    Name = "ansible_security_group"
  }
}


resource "aws_instance" "ansible_demo" {
  for_each   = toset(var.machines)
  ami           = data.aws_ami.ubuntu.id  
  instance_type = "t2.micro"
  security_groups = [aws_security_group.main.name]
  user_data = file("files/userdata.sh")
  tags = {
    Name = "${each.key}"
  }
}


variable "machines" {
    default = ["jenkins"]
}

# Output SSH connection strings
output "ssh_connect_strings" {
  value = [
    for idx in var.machines : 
    "ssh ansible@${aws_instance.ansible_demo[idx].public_ip}"
  ]
}

output "jenkins_url" {
  value = [
    for idx in var.machines : 
    "https://${aws_instance.ansible_demo[idx].public_ip}:8080"
    ]
}