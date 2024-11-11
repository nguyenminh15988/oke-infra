
variable "tenancy_ocid" {
  description = "The OCID of the tenancy"
  type        = string
}

variable "user_ocid" {
  description = "The OCID of the user"
  type        = string
}

variable "fingerprint" {
  description = "The fingerprint for the public key"
  type        = string
}

variable "private_key_path" {
  description = "Path to the private key file"
  type        = string
}

variable "region" {
  description = "OCI region"
  type        = string
}

variable "compartment_id" {
  description = "The OCID of the compartment"
  type        = string
}

variable "availability_domain" {
  description = "The Availability Domain where the resources will be created"
  type        = string
}

variable "ubuntu_image_id" {
  description = "The OCID of the ubuntu Linux image"
  type        = string
}

variable "oracle_linux_image_id" {
  description = "The OCID of the oracle Linux image"
  type        = string
}
variable "ssh_key_path" {
  description = "The file path to the public SSH key to be used for the instance"
  type        = string
  default     = "~/.ssh/vsee_rsa.pub"  
}
