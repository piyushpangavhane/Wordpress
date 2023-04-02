provider "aws" {
  region     = "us-east-2"
  access_key = var.access_key
  secret_key = var.secret_key
  # access_key = var.AWS_ACCESS_KEY_ID
  # secret_key = var.AWS_SECRET_ACCESS_KEY
}

resource "random_string" "String" {
  length = 5

}

resource "aws_security_group" "Webaccess" {
  name        = "WebAccess"
  description = "For Webserver"
  vpc_id      = "vpc-07b34446f8c835427"
  // Dynamic block is used to calling otu any loop conditions, same as below instead of sepcifying many ingress block, using dynamic block instead of it
  dynamic "ingress" {
    for_each = var.ports
    iterator = port
    content {
      cidr_blocks = ["0.0.0.0/0"]
      description = "SSH"
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
    }

  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #   ingress {
  #     cidr_blocks = ["0.0.0.0/0"]
  #     description = "SSH"
  #     from_port   = 22
  #     to_port     = 22
  #     protocol    = "tcp"

  tags = {
    "Environment" = "Staging"
  }

}
// Print out file content from the referenced file
output "PrintfileContent" {
  value = file("${path.module}/id_rsa.pub")
}

// AWS Key Pair
resource "aws_key_pair" "AWSKeypair" {
  key_name   = "StagingkeyPair"
  public_key = file("${path.module}/id_rsa.pub")
}

resource "aws_instance" "this" {
  ami = data.aws_ami.ubuntu.id // referencing image id form data block which had filtered out the results
  #count = 2
  instance_type          = var.instance_type
  vpc_security_group_ids = ["${aws_security_group.Webaccess.id}"]
  key_name               = aws_key_pair.AWSKeypair.key_name
  #   user_data = <<EOF
  # #!/bin/bash
  # sudo apt-get update -y
  # sudo apt-get install nginx -y
  #   EOF


  // Global Connection block
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${path.module}/id_rsa")
    host        = self.public_ip
  }

  // provisioner to move to local content to Remote machine
  provisioner "file" {
    source      = "id_rsa"
    destination = "/tmp/id_rsa"

  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install nginx -y",
      "echo 'aaa' > a.text"
    ]

    // connection block defined for particular provisioner
    # connection {
    #   type = "ssh"
    #   user = "ubuntu"
    #   private_key = file("${path.module}/id_rsa")
    #   host = self.public_ip
    # }
  }

  # provisioner "remote-exec" {
  #   when = destroy
  #   inline = [
  #     "aws s3 cp /var/www/html/d.txt s3://patil123ew"

  #   ]
  # }
}

// Data Source block for AWS EC2 AMI details 

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["${var.owner}"]
  filter {
    name   = "name"
    values = ["${var.image_name}"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
