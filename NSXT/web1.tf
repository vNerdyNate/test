resource "vsphere_virtual_machine" "web1" {
  name             = "web1-Box"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id


  num_cpus = 2
  memory   = 4096
  guest_id = data.vsphere_virtual_machine.template.guest_id
  
  scsi_type = "lsilogic"
  
  efi_secure_boot_enabled = "false"
  firmware = "bios"

  network_interface {
    network_id = data.vsphere_network.network.id
  }
  disk {
    label            = "disk1"
    size             = data.vsphere_virtual_machine.template.disks.0.size
    eagerly_scrub    = "false"
    thin_provisioned = "true"
  }
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name   = "Ubuntu-Box"
        #join_domain = "nerdy.io"
        #domain_admin_user = "_svcvra@masterdomain.local"
        #domain_admin_password = "VM@uto4A!"
        #admin_password = "VMware1!"
        domain      = "Sterling.lab"
      }
    

      network_interface {
        ipv4_address = "10.150.166.21"
        ipv4_netmask = 24
       
      }
      ipv4_gateway = "10.150.166.1"
      dns_server_list = ["10.150.100.251"]
    }
  }
  provisioner "file" {
    source      = "web.sh"
    destination = "/tmp/web.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/web.sh",
      "/tmp/web.sh",
    ]
  }
  connection {
    type     = "ssh"
    user     = "root"
    password = var.vpassword
    host     = "10.150.166.21"
  }

  depends_on = [
    vsphere_virtual_machine.SQL
  ]
}