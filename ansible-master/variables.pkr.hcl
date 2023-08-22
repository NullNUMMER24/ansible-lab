variable "iso_url" {
  type      = string
  default   = "https://releases.ubuntu.com/jammy/ubuntu-22.04.3-live-server-amd64.iso"
}
variable "iso_checksum" {
  type      = string
  default   = "file:https://releases.ubuntu.com/jammy/SHA256SUMS"
}
variable "ssh_username" {
  type      = string
  default   = "root"
}
variable "ssh_password" {
  type      = string
  default   = "Pa$$w0rd"
}
variable "name" {
  type      = string
  default   = "ubuntu"
}
