

output "SecurityGRP" {
  value = aws_security_group.Webaccess.id
}

# output "Public" {
#     value = aws_instance.this[1].public_ip
# }

output "AMI" {
  value = data.aws_ami.ubuntu.id

}
output "IP" {
  value = aws_instance.this.public_ip

}
