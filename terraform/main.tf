variable "hcloud_token" {}

terraform {
  required_providers {
    hcloud = {
      source       = "hetznercloud/hcloud"
    }
  }
}

provider "hcloud" {
  token           = "${var.hcloud_token}"
}