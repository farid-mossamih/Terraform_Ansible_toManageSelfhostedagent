locals {
  ssh_user         = "ubuntu"
  key_name         = "main-key"
  private_key_path = "~/main-key.pem"
}
provider "aws" {
  region = "eu-west-3"
    access_key = "*********************"
    secret_key = "*************************"
}

resource "aws_instance" "instace_for_ansible_role" {
  ami           = "ami-***************"
  instance_type = "t2.micro"
  subnet_id = "subnet-3600ef5e"
  key_name = local.key_name
  tags = {
    Name = "Slave"
  }
  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file(local.private_key_path)
      host        = aws_instance.instace_for_ansible_role.public_ip
    }
  } 


  provisioner "local-exec" {
    command = "ansible-playbook -u ubuntu -i '${aws_instance.instace_for_ansible_role.public_ip},' --private-key ${local.private_key_path} -T 600  playbook.yml"
  }
}
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.instace_for_ansible_role.tags.Name
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.instace_for_ansible_role.public_ip
}
