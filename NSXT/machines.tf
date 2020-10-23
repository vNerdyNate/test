resource "vsphere_virtual_machine" "SQL" {
  name             = "SQL-Box"
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
    size             = "50"
    eagerly_scrub    = "false"
    thin_provisioned = "true"
  }
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name   = "SQL-Box"
        domain      = "Sterling.lab"
      }
    
      network_interface {}
    }
  }
  
  provisioner "remote-exec" {
    inline = [
      "/home/ubuntu/sql.sh",
    ]
  }
  connection {
    type     = "ssh"
    user     = "root"
    password = var.vpassword
    host     = vsphere_virtual_machine.SQL.default_ip_address
  }
}
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
        host_name   = "web1-box"
        domain      = "Sterling.lab"
      }
    

      network_interface {}
    }
  }
  provisioner "remote-exec" {
    inline = [
      "/home/ubuntu/web.sh ${vsphere_virtual_machine.SQL.default_ip_address}",
    ]
  }
  connection {
    type     = "ssh"
    user     = "root"
    password = var.vpassword
    host     = vsphere_virtual_machine.web1.default_ip_address
  }

  depends_on = [
    vsphere_virtual_machine.SQL
  ]
}
resource "vsphere_virtual_machine" "web2" {
  name             = "web2-Box"
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
        host_name   = "web2-box"
        domain      = "Sterling.lab"
      }
      network_interface {}
    }
  }

  provisioner "remote-exec" {
    inline = [
      "/home/ubuntu/web.sh ${vsphere_virtual_machine.SQL.default_ip_address}",
    ]
  }
  connection {
    type     = "ssh"
    user     = "root"
    password = var.vpassword
    host     = vsphere_virtual_machine.web2.default_ip_address
  }

  depends_on = [
    vsphere_virtual_machine.SQL
  ]
}
