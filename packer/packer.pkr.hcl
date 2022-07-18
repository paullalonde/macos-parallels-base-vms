packer {
  required_version = "~> 1.8"

  required_plugins {
    parallels = {
      version = ">= 1.0.3"
      source  = "github.com/hashicorp/parallels"
    }
  }
}

variable "disk_size" {
  description = "The size of the VM's disk."
  type        = number
  default     = 65000
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
  pvm_name     = "${local.vm_name}.pvm"
  tgz_name     = "${local.pvm_name}.tgz"
  sha256_name  = "${local.tgz_name}.sha256"
}

source "parallels-iso" "base" {
  vm_name              = local.vm_name
  output_directory     = "build"
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
  disk_size            = var.disk_size
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
    script = "scripts/package-vm.sh"

    env = {
      PVM_NAME    = local.pvm_name,
      SHA256_NAME = local.sha256_name,
      TGZ_NAME    = local.tgz_name,
    }
  }

  # The tgz and its checksum are now the artifacts.
  post-processor "artifice" {
    files = [
      "output/${local.tgz_name}",
      "output/${local.sha256_name}",
    ]
  }

  # The VM is packaged as a tgz under ./output, so we don't need the built VM anymore.
  post-processor "shell-local" {
    inline = [
      "rm -rf build/${local.pvm_name}"
    ]
  }
}
