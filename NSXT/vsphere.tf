terraform {
  required_providers {
    nsxt = {
      source = "vmware/nsxt"
      version = "3.1.0"
    }
  }
}

provider "vsphere" {
  user           = var.vuser
  password       = var.vpassword
  vsphere_server = var.vserver

  # If you have a self-signed cert
  allow_unverified_ssl = true
}
provider "nsxt" {
  host                     = "vra-nsxt-01.sterling.lab"
  username                 = var.nsuser
  password                 = var.nspass
  allow_unverified_ssl     = true
  max_retries              = 10
  retry_min_delay          = 500
  retry_max_delay          = 5000
  retry_on_status_codes    = [429]
}
data "vsphere_datacenter" "dc" {
  name = "Pacific-Datacenter"
}

data "vsphere_datastore" "datastore" {
  name          = "vsanDatastore"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = "IaC"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = "vRA-Segment-01"
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_virtual_machine" "template" {
  name          = "ubuntu20TF"
  datacenter_id = data.vsphere_datacenter.dc.id
}
