variable "access_key" {

}
variable "secret_key" {

}

# variable "AWS_ACCESS_KEY_ID" {
#   type = string
# }
# variable "AWS_SECRET_ACCESS_KEY" {
#   type = string
# }

variable "image" {

}
variable "instance_type" {

}
variable "ports" {
  type    = list(number)
  default = [22, 80, 443, 3306]
}

variable "owner" {

}
variable "image_name" {

}
