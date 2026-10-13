variable "proxmox_endpoint" {
  type        = string
  description = "Proxmox API URL, z. B. https://10.10.10.10:8006/"
}
variable "proxmox_api_token" {
  type        = string
  sensitive   = true
  description = "API-Token: user@realm!tokenid=secret  – via TF_VAR_proxmox_api_token setzen"
}
variable "proxmox_tls_insecure" {
  type    = bool
  default = true
}
variable "ssh_public_key" {
  type        = string
  description = "SSH-Public-Key für cloud-init"
}
