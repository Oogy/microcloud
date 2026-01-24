packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = ">= 1.0.0"
    }
  }
}

locals {
  iso_url = "${var.iso_url_base}/${var.iso_url_version}/${var.iso_url_image}"
}

source "qemu" "image" {
  iso_url          = local.iso_url
  iso_checksum     = var.iso_checksum
  output_directory = var.output_directory
  disk_image       = var.disk_image
  format           = var.format
  ssh_username     = var.ssh_username
  ssh_password     = var.ssh_password
  boot_wait        = var.boot_wait
  shutdown_command = var.shutdown_command
  vm_name          = var.vm_name
}

build {
  sources = ["source.qemu.image"]

  provisioner "file" {
    source = "files/dnsmasq.conf"
    destination = "/tmp/dnsmasq.conf"
  }

  provisioner "shell" {
    inline = [
      "sudo pacman -Syu --noconfirm",
      "sudo grub-mkconfig -o /boot/grub/grub.cfg",
      "sudo pacman -S dnsmasq intel-ucode amd-ucode neovim --noconfirm",
      "sudo mkdir /srv/tftp",
      "sudo cp /tmp/dnsmasq.conf /etc/dnsmasq.conf",
      "sudo systemctl enable dnsmasq"
    ]
  }

  post-processor "shell-local" {
    inline = [
      "qemu-img convert -f qcow2 -O raw ${var.output_directory}/packer-${var.vm_name} ${var.output_directory}/${var.vm_name}.raw"
    ]
  }
}
