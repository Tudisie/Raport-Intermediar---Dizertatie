resource "aws_instance" "learning_platform_java_ami_server" {
  ami           = "ami-0eabf696a86fe8296"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  key_name = "learning-platform-key"

  network_interface {
    network_interface_id = var.nic_id
    device_index         = 0
  }

  tags = {
    Name = "LearningPlatformInstance"
  }
}