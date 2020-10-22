data "nsxt_policy_tier0_gateway" "T0" {
  display_name = "Pacific-T0-Gateway"
}

data "nsxt_policy_edge_cluster" "EC" {
  display_name = "Edge-Cluster-01"
}

data "nsxt_policy_transport_zone" "vlantz" {
  display_name = "TZ-Overlay"
}

module "segment" {
    source = "./modules/segment"


}
/*
resource "nsxt_policy_tier1_gateway" "tier1_tf" {
  description               = "Tier-1 provisioned by Terraform"
  display_name              = "tier1-tf"
  nsx_id                    = "predefined_id"
  edge_cluster_path         = data.nsxt_policy_edge_cluster.EC.path
  failover_mode             = "PREEMPTIVE"
  default_rule_logging      = "false"
  enable_firewall           = "true"
  enable_standby_relocation = "false"
  force_whitelisting        = "true"
  tier0_path                = data.nsxt_policy_tier0_gateway.T0.path
  route_advertisement_types = ["TIER1_STATIC_ROUTES", "TIER1_CONNECTED", "TIER1_LB_SNAT"]
  pool_allocation           = "ROUTING"

  tag {
    scope = "color"
    tag   = "blue"
  }
  route_advertisement_rule {
    name                      = "TF-LB1"
    action                    = "PERMIT"
    subnets                   = ["0.0.0.0/0", "10.150.166.0/24"]
    prefix_operator           = "GE"
    route_advertisement_types = ["TIER1_CONNECTED"]
  }

}


resource "nsxt_policy_tier1_gateway_interface" "if1" {
  display_name           = "segment1_interface"
  description            = "connection to segment1"
  gateway_path           = data.nsxt_policy_tier1_gateway.tier1.path
  segment_path           = module.segment.segment.path
  subnets                = ["10.150.165.5/24"]
  mtu                    = 1500
}

resource "nsxt_policy_dhcp_server" "test" {
  display_name      = "test"
  description       = "Terraform provisioned DhcpServerConfig"
  edge_cluster_path = data.nsxt_policy_edge_cluster.EC.path
  lease_time        = 200
  server_addresses  = ["10.150.167.251/24"]
}

/*resource "nsxt_policy_vlan_segment" "vlansegment1" {
  display_name        = "vlansegment1"
  description         = "Terraform provisioned VLAN Segment"
  transport_zone_path = data.nsxt_policy_transport_zone.vlantz.path
  domain_name         = "sterling.lab"
  vlan_ids            = ["101", "102"]

  subnet {
    cidr        = "10.150.165.1/24"
  }

  advanced_config {
    connectivity = "OFF"
    local_egress = true
  }
}*/

resource "nsxt_policy_lb_pool" "test" {
    display_name         = "test"
    description          = "Terraform provisioned LB Pool"
    algorithm            = "ROUND_ROBIN"
    min_active_members   = 2
    active_monitor_path  = "/infra/lb-monitor-profiles/default-icmp-lb-monitor"
    #passive_monitor_path = "/infra/lb-monitor-profiles/default-passive-lb-monitor"
    
    member {
      admin_state                = "ENABLED"
      backup_member              = false
      display_name               = "web1"
      ip_address                 = "10.150.166.21"
      max_concurrent_connections = 12
      port                       = "80"
      weight                     = 1
    }
    member {
      admin_state                = "ENABLED"
      backup_member              = false
      display_name               = "web2"
      ip_address                 = "10.150.166.22"
      max_concurrent_connections = 12
      port                       = "80"
      weight                     = 1
    }
    snat {
       type = "AUTOMAP"
    }
    tcp_multiplexing_enabled = false
    tcp_multiplexing_number  = 8
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
  service_path               = nsxt_policy_lb_service.test.path
  max_concurrent_connections = 6
  max_new_connection_rate    = 20
  pool_path                  = nsxt_policy_lb_pool.test.path
  #sorry_pool_path            = nsxt_policy_lb_pool.test.path

}
resource "nsxt_policy_lb_service" "test" {
  display_name      = "test"
  description       = "Terraform provisioned Service"
  connectivity_path = module.segment.t1.path
  size = "SMALL"
  enabled = true
  error_log_level = "ERROR"
}
