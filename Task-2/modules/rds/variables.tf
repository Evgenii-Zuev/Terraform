variable "name" {
  default = "keep" # change
}
variable "project_mysql" {
  default = "/project/mysql"
}
variable "allow-subnets" {
  description = "Allow subnets"
  type        = list(any)
}
variable "allow-sg" {
  description = "Allow securiry group"
  type        = list(any)
}
