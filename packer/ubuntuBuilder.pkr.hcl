packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1"
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
  default   = "30000"
}
variable "http_directory" {
  type      = string
  default   = "http"
}
variable "iso_url" {
  type      = string
  default   = ""
}
variable "iso_checksum" {
  type      = string
  default   = ""
}
variable "ssh_username" {
  type      = string
  default   = "root"
}
variable "ssh_password" {
  type      = string
  default   = "sml12345"
}
variable "name" {
  type      = string
  default   = ""
}
variable "os_name" {
  type      = string
  default   = ""
}

locals {
  time        = formatdate("YYYY-MM-DD", timestamp())
  os_infos = {
    "ubuntu" = {
     "boot_command" = [
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
     ],
   }
   "almalinux" = {
    "boot_command" = [
      "<up><wait><tab><wait> text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg<enter><wait>"
      ]
    }


  }
  boot_command = local.os_infos[var.name].boot_command
}

source "qemu" "kvm-standard" {
  iso_url           = var.iso_url
  iso_checksum      = var.iso_checksum
  output_directory  = "ubuntu-test"
  shutdown_command  = "echo 'packer' | sudo -S shutdown -P now"
  disk_size         = var.disk_size
  memory            = "5000"
  headless          = false
  format            = "qcow2"
  accelerator       = "kvm"
  http_directory    = var.http_directory
  ssh_username      = "root"
  ssh_password      = "r-00+lin"
  ssh_timeout       = "50m"
  vm_name           = var.name
  net_device        = "virtio-net"
  disk_interface    = "virtio"
  boot_command      = local.boot_command
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
  boot_command         = split("|", replace(join("|", local.boot_command), "vda", "sda"))
  boot_wait            = "10s"
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
  ssh_timeout          = "30m"
  ssh_username         = var.ssh_username
  vboxmanage           = [["modifyvm", "{{ .Name }}", "--memory", "2048"], ["modifyvm", "{{ .Name }}", "--cpus", "1"], ["modifyvm", "{{.Name}}", "--nat-localhostreachable1", "on"]]
  vm_name              = local.name
  guest_os_type        = "Ubuntu_64"
}

build {
  sources = [
    "source.qemu.kvm-standard",
    "source.virtualbox-iso.vbox"
    ]

  provisioner "shell" {
    only = ["qemu.kvm-standard"]
    inline = [
    "rm /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
    "rm /etc/netplan/00-installer-config.yaml"
    ]
  }

  provisioner "shell" {
    scripts = [
      "scripts/vagrant_user.sh"
      ]
  }

  post-processors {
    post-processor "vagrant" {
      only = ["virtualbox-iso.vbox"]
      keep_input_artifact = false
      output = "${var.name}.box"
    }
    post-processor "vagrant" {
      only = ["qemu.kvm-standard"]
      keep_input_artifact = false
      output = "${var.name}.box"
      include = [
        "files/info.json",
        "files/metadata.json"
      ]
    }
  }
}
