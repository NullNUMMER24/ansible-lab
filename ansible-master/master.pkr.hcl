packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = ">= 1.0.9"
    }
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = "~> 1"
    }
    virtualbox = {
      source = "github.com/hashicorp/virtualbox"
      version = "~> 1"
    }
  }
}

variable "disk_size" {
  type      = string
  default   = "10000"
}
variable "http_directory" {
  type      = string
  default   = "http"
}
variable "output_directory" {
  type      = string
  default   = "ansible-out"
}

locals {
  time        = formatdate("YYYY-MM-DD", timestamp())
  BootCommand = [
    "<wait>",
    "<wait>",
    "<wait>",
    "<wait>",
    "<wait>",
    "c",
    "<wait>",
    "linux /casper/vmlinuz <wait>",
    " autoinstall<wait>",
    " ds=nocloud-net<wait>",
    "\\;s=http://<wait>",
    "{{.HTTPIP}}<wait>",
    ":{{.HTTPPort}}/ubuntu/<wait>",
    " ---",
    "<enter><wait>",
    "initrd /casper/initrd<wait>",
    "<enter><wait>",
    "boot<enter><wait>"
  ]
}

source "qemu" "kvm-standard" {
  iso_url           = var.iso_url
  iso_checksum      = var.iso_checksum
  output_directory  = var.output_directory
  shutdown_command  = "echo 'packer' | sudo -S shutdown -P now"
  disk_size         = var.disk_size
  memory            = "5000"
  headless          = false
  format            = "qcow2"
  accelerator       = "kvm"
  http_directory    = var.http_directory
  ssh_username      = var.ssh_username
  ssh_password      = var.ssh_password
  ssh_timeout       = "50m"
  vm_name           = var.name
  net_device        = "virtio-net"
  disk_interface    = "virtio"
  boot_command      = local.BootCommand
  boot_wait         = "10s"
  qemuargs         = [
    ["-m", "5000M"],
    ["-smp", "2"],
    ["-rtc", "base=localtime,driftfix=slew"],
    ["-cpu", "host,hv_relaxed,hv_vapic,hv_spinlocks=0x1fff"],
    [ "-global", "virtio-blk-pci.physical_block_size=4096" ]
  ]
}

source "virtualbox-iso" "vbox" {
  boot_command         = split("|", replace(join("|", local.BootCommand), "vda", "sda"))
  boot_wait            = "5s"
  communicator         = "ssh"
  disk_size            = var.disk_size
  guest_additions_mode = "upload"
  guest_additions_path = "VBoxGuestAdditions.iso"
  hard_drive_interface = "sata"
  http_directory       = var.http_directory
  headless             = false
  iso_url              = var.iso_url
  iso_checksum         = var.iso_checksum
  shutdown_command     = "echo 'packer' | sudo -S shutdown -P now" 
  ssh_password         = var.ssh_password
  ssh_timeout          = "15m"
  ssh_username         = var.ssh_username
  vboxmanage           = [["modifyvm", "{{ .Name }}", "--memory", "2048"], ["modifyvm", "{{ .Name }}", "--cpus", "1"]]
  vm_name              = local.name
}

build {
  sources = ["source.qemu.kvm-standard"]

  provisioner "shell" {
    inline = [
    "rm /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
    "rm /etc/netplan/00-installer-config.yaml"
    ]
  } 

  provisioner "shell" {
    scripts = [
      "../scripts/ansible-install.sh",
      "../scripts/vagrant_user.sh",
      ]
  }

  post-processors {
    post-processor "vagrant" {
      keep_input_artifact = false
      output = "/home/jamie/git/ansible-lab/boxes/ansible-master.box"
    }
    }
  }
