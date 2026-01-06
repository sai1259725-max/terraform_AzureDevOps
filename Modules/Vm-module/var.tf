variable "rgname" {
  type = string
}
variable "rglocation" {
  type = string
  #default = "central"
}
variable "subnetid" {
  type = string
}
variable "vmname" {
  type = string
}
variable "vmsize" {
  type = string
}
variable "vmusername" {
  type = string
}
variable "vmpassword" {
  sensitive = true
}