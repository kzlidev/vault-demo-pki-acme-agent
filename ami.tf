data "aws_ami" "ubuntu_jammy_24_04" {
  filter {
    name   = "name"
    values = [var.ami_name]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
  most_recent = true
  owners      = [var.ami_owner]
}