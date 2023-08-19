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
  }
}
source "qemu" "kvm-standard" {
  iso_url           = "https://releases.ubuntu.com/jammy/ubuntu-22.04.3-live-server-amd64.iso"
  iso_checksum      = "file:https://releases.ubuntu.com/jammy/SHA256SUMS"
  output_directory = ansible-master-box
  shutdown_command  = "echo 'packer' | sudo -S shutdown -P now"
  disk_size         = "10000"
  memory            = "3000"
  headless          = false
  format            = "qcow2"
  accelerator       = "kvm"
  http_directory    = "http"
  ssh_username      = "root"
  ssh_password      = "Pa$$w0rd"
  ssh_timeout       = "50m"
  vm_name           = "ansible-master"
  net_device        = "virtio-net"
  disk_interface    = "virtio"
  boot_wait         = "10s"
  qemuargs         = [
    ["-m", "5000M"],
    ["-smp", "2"],
    ["-rtc", "base=localtime,driftfix=slew"],
    ["-cpu", "host,hv_relaxed,hv_vapic,hv_spinlocks=0x1fff"],
    [ "-global", "virtio-blk-pci.physical_block_size=4096" ]
  ]

  boot_command      = [
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
      "./vagrant_user.sh",
      "./install.sh"
      ]
  }

  post-processors {
    post-processor "vagrant" {
      keep_input_artifact = false
      output = "../boxes/ansible-master.box"
    }
    }
  }
