
resource "oci_core_vcn" "dev_vcn" {
  cidr_block     = "10.0.0.0/16"
  display_name   = "dev_vcn"
  compartment_id = var.compartment_id
}

resource "oci_core_internet_gateway" "dev_ig" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.dev_vcn.id
  enabled        = true
}

resource "oci_core_route_table" "dev_rt" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.dev_vcn.id

  route_rules {
    destination = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.dev_ig.id
  }
}

resource "oci_core_subnet" "dev_subnet" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.dev_vcn.id
  cidr_block     = "10.0.1.0/24"
  security_list_ids = [oci_core_security_list.dev_sl.id]
  route_table_id = oci_core_route_table.dev_rt.id
}

resource "oci_core_security_list" "dev_sl" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.dev_vcn.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol    = "6"  // TCP
    source      = "0.0.0.0/0"
    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    protocol    = "6"  // TCP
    source      = "0.0.0.0/0"
    tcp_options {
      min = 443
      max = 443
    }
  }
}

