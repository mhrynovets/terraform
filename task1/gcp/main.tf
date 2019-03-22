provider "google" {
  credentials = "${file("files/cred.json")}"
  project = "avian-bricolage-231816"
  version = "~> 2.2"
  region  = "${var.region}"
  zone    = "${var.zone}"
}

resource "google_compute_instance" "default" {
  name         = "${var.prefix}-vm-01"
  machine_type = "g1-small"
  zone         = "${var.zone}"
  
  tags = ["dev", "qa", "stg", "web"]

  boot_disk {
    initialize_params {
      image = "${var.osimage}"
    }
  }

  attached_disk {
    source = "${google_compute_disk.ssd.name}"
  }

  attached_disk {
    source = "${google_compute_disk.hdd.name}"
  }

  provisioner "file" {
    source      = "files/initweb.sh"
    destination = "/tmp/initweb.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/initweb.sh",
      "/tmp/initweb.sh",
    ]
  }
  connection {
      type        = "ssh"
      user        = "devops"
      timeout     = "500s"
      private_key = "${file("files/devops.pem")}"
  }

  metadata {
    sshKeys = "devops:${file("files/devops.pub")}"
  }

  network_interface {
    network = "default"

    access_config {
      // Include this section to give the VM an external ip address
    }
  }
}

resource "google_compute_disk" "ssd" {
  name  = "${var.prefix}-ssd-1"
  type  = "pd-ssd"
  zone  = "${var.zone}"
  size  = "50"
}

resource "google_compute_disk" "hdd" {
  name  = "${var.prefix}-hdd-1"
  type  = "pd-standard"
  zone  = "${var.zone}"
  size  = "50"
}

resource "google_compute_firewall" "default" {
  name    = "network-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "8080"]
  }

  target_tags = ["web"]
}
