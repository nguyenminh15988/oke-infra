resource "oci_containerengine_cluster" "oke_cluster" {
  name              = "my-oke-cluster"
  compartment_id    = var.compartment_id
  vcn_id            = oci_core_vcn.dev_vcn.id
  kubernetes_version = "v1.30.1"

  options {
    service_lb_subnet_ids = [oci_core_subnet.dev_subnet.id]
  }
}

resource "oci_core_subnet" "oke_node_pool_subnet" {
  compartment_id       = var.compartment_id
  vcn_id               = oci_core_vcn.dev_vcn.id
  cidr_block           = "10.0.2.0/24"
  display_name         = "oke-node-pool-subnet"
  route_table_id       = oci_core_route_table.dev_rt.id
  security_list_ids    = [oci_core_security_list.dev_sl.id]
  prohibit_public_ip_on_vnic = false
}

resource "oci_containerengine_node_pool" "oke_node_pool" {
  cluster_id        = oci_containerengine_cluster.oke_cluster.id
  compartment_id    = var.compartment_id
  name              = "oke-node-pool"
  node_shape        = "VM.Standard.E3.Flex"
  kubernetes_version = "v1.30.1"

  node_config_details {
    size = 1  # Initial number of nodes

    placement_configs {
      availability_domain = var.availability_domain
      subnet_id           = oci_core_subnet.oke_node_pool_subnet.id  # Use the correct subnet here
    }
  }

  node_shape_config {
    ocpus         = 2  # Adjust based on your requirements
    memory_in_gbs = 16 # Adjust based on your requirements
  }

  node_source_details {
    source_type = "image"
    image_id    = var.oracle_linux_image_id
  }

  initial_node_labels {
    key   = "environment"
    value = "production"
  }
}



