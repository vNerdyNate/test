data "nsxt_policy_tier0_gateway" "T0" {
  display_name = "Pacific-T0-Gateway"
}

data "nsxt_policy_edge_cluster" "EC" {
  display_name = "Edge-Cluster-01"
}

data "nsxt_policy_transport_zone" "vlantz" {
  display_name = "TZ-Overlay"
}
resource "nsxt_policy_tier1_gateway" "tier1_tf" {
  description               = "Tier-1 provisioned by Terraform"
  display_name              = "tier1-tf"
  nsx_id                    = "predefined_id"
  edge_cluster_path         = data.nsxt_policy_edge_cluster.EC.path
  failover_mode             = "NON_PREEMPTIVE"
  default_rule_logging      = "false"
  enable_firewall           = "false"
  enable_standby_relocation = "false"
  force_whitelisting        = "true"
  tier0_path                = data.nsxt_policy_tier0_gateway.T0.path
  route_advertisement_types = ["TIER1_STATIC_ROUTES", "TIER1_CONNECTED", "TIER1_LB_SNAT", "TIER1_LB_VIP"]
  pool_allocation           = "ROUTING"
  
  tag {
    scope = "Provisioner"
    tag   = "Terraform"
  }
}


resource "nsxt_firewall_section" "firewall_sect" {
  description  = "FW provisioned by Terraform"
  display_name = "FW"

  tag {
    scope = "Built_by"
    tag   = "Teraform"
  }


  section_type  = "LAYER3"
  stateful      = true

  rule {
    display_name          = "out_rule"
    description           = "Out going rule"
    action                = "ALLOW"
    logged                = true
    ip_protocol           = "IPV4"
    direction             = "IN_OUT"
    destinations_excluded = "false"
  }
}

resource "nsxt_policy_lb_pool" "tf_pool" {
    display_name         = "test"
    description          = "Terraform provisioned LB Pool"
    algorithm            = "ROUND_ROBIN"
    min_active_members   = 2
    active_monitor_path  = "/infra/lb-monitor-profiles/default-icmp-lb-monitor"
    
    member {
      admin_state                = "ENABLED"
      backup_member              = false
      display_name               = "web1"
      ip_address                 = vsphere_virtual_machine.web1.default_ip_address
      max_concurrent_connections = 12
      port                       = "80"
      weight                     = 1
    }
    member {
      admin_state                = "ENABLED"
      backup_member              = false
      display_name               = "web2"
      ip_address                 = vsphere_virtual_machine.web2.default_ip_address
      max_concurrent_connections = 12
      port                       = "80"
      weight                     = 1
    }
    snat {
       type = "AUTOMAP"
    }
    tcp_multiplexing_enabled = false
    tcp_multiplexing_number  = 8
tag {
    scope = "Provisioner"
    tag   = "Terraform"
  }
}

data "nsxt_policy_lb_app_profile" "test" {
  type         = "HTTP"
  display_name = "default-http-lb-app-profile"
}

resource "nsxt_policy_lb_virtual_server" "test" {
  display_name               = "test"
  description                = "Terraform provisioned Virtual Server"
  access_log_enabled         = true
  application_profile_path   = "/infra/lb-app-profiles/default-http-lb-app-profile"
  enabled                    = true
  ip_address                 = "10.150.166.5"
  ports                      = ["80"]
  default_pool_member_ports  = ["80"]
  service_path               = nsxt_policy_lb_service.tf_loadbalancer.path
  max_concurrent_connections = 6
  max_new_connection_rate    = 20
  pool_path                  = nsxt_policy_lb_pool.tf_pool.path

  tag {
    scope = "Provisioner"
    tag   = "Terraform"
  }

}

resource "nsxt_policy_lb_service" "tf_loadbalancer" {
  display_name      = "test"
  description       = "Terraform provisioned Service"
  connectivity_path = nsxt_policy_tier1_gateway.tier1_tf.path
  size = "SMALL"
  enabled = true
  error_log_level = "ERROR"

  tag {
    scope = "Provisioner"
    tag   = "Terraform"
  }
}
