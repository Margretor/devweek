provider "profitbricks" {
  version = "~> 1.5.4"
}

# Managed Kubernetes Cluster
resource "profitbricks_k8s_cluster" "wp_hoster" {
  name        = "wp_hoster"
  k8s_version = "1.18.5"
  depends_on = [ profitbricks_datacenter.vdc1 ]
  maintenance_window {
    day_of_the_week = "Sunday"
    time = "10:30:00Z"
  }
}

# VDC1 (de/fra)
resource "profitbricks_datacenter" "vdc1" {
  name        = "vdc1"
  location    = "de/fra"
}

# Crossconnect LANs
resource "profitbricks_lan" "crosslink_vdc1" {
  datacenter_id = profitbricks_datacenter.vdc1.id
  name          = "crosslink"
  public        = false
  # pcc           = profitbricks_private_crossconnect.crosslink.id
}

# VDC1 (de/fra) Node pool
resource "profitbricks_k8s_node_pool" "wp_hoster_vdc1" {
    availability_zone = "AUTO"
    cores_count       = 2
    cpu_family        = "INTEL_SKYLAKE"
    datacenter_id     = profitbricks_datacenter.vdc1.id
    k8s_cluster_id    = profitbricks_k8s_cluster.wp_hoster.id
    k8s_version       = "1.18.5"
    name              = "wp_hoster_vdc1"
    node_count        = 1
    ram_size          = 6144
    storage_size      = 120
    storage_type      = "SSD"
    depends_on        = [ profitbricks_k8s_cluster.wp_hoster ]
    auto_scaling {
        max_node_count = 3
        min_node_count = 1
    }
    lans = [ profitbricks_lan.crosslink_vdc1.id ]
    maintenance_window {
        day_of_the_week = "Saturday"
        time            = "09:00:00Z"
    }
}
