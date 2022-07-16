packer {
  required_version = "~> 1.8"

  required_plugins {
    parallels = {
      version = ">= 1.0.3"
      source  = "github.com/hashicorp/parallels"
    }
  }
}

variable "iso_checksum" {
  description = "The bootable macOS ISO image's checksum."
  type        = string
}

variable "iso_url" {
  description = "The URL of the bootable macOS ISO image."
  type        = string
}

variable "os_name" {
  description = "The name of version of macOS."
  type        = string
}

variable "ssh_password" {
  description = "The password of the user connecting to the VM via SSH."
  type        = string
  sensitive   = true
}

locals {
  ssh_username = "packer"
  vm_name      = "macos-${var.os_name}-base"
}

source "parallels-iso" "base" {
  vm_name              = local.vm_name
  output_directory     = "vms"
  guest_os_type        = "macosx"
  iso_url              = var.iso_url
  iso_checksum         = var.iso_checksum
  parallels_tools_mode = "disable"
  ssh_username         = local.ssh_username
  ssh_password         = var.ssh_password
  ssh_timeout          = "8h"
  cpus                 = 2
  memory               = 4096
  disk_type            = "plain"
  disk_size            = 65000
  shutdown_command     = "echo '${var.ssh_password}' | sudo -S shutdown -h now"
  shutdown_timeout     = "10m"
  skip_compaction      = true
}

build {
  name = "base"

  sources = [
    "source.parallels-iso.base",
  ]

  provisioner "breakpoint" {
    disable = false
    note    = "WAITING FOR THE MANUAL STEPS TO BE PERFORMED WITHIN THE VM ..."
  }

  post-processor "shell-local" {
    inline = [
      "set -eu",
      "mkdir -p output",
      "echo 'Creating tgz archive of VM ...'",
      "tar -czf output/${local.vm_name}.tgz -C vms ${local.vm_name}.pvm",
      "echo 'Computing checksum ...'",
      "pushd output >/dev/null",
      "sha256sum ${local.vm_name}.tgz >${local.vm_name}.tgz.sha256",
      "touch -r ${local.vm_name}.tgz ${local.vm_name}.tgz.sha256",
      "popd >/dev/null",
    ]
  }

  # The tgz and its checksum are now the artifacts.
  post-processor "artifice" {
    files = [
      "output/${local.vm_name}.tgz",
      "output/${local.vm_name}.tgz.sha256",
    ]
  }
}
