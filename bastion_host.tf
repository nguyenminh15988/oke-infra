resource "oci_core_instance" "bastion" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  shape               = "VM.Standard.E3.Flex"

  shape_config {
    ocpus         = 2  # Adjust based on your requirements
    memory_in_gbs = 16 # Adjust based on your requirements
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.dev_subnet.id
    assign_public_ip = true  # Set based on your needs
  }

  source_details {
    source_type = "image"
    source_id   = var.ubuntu_image_id  # Use the OCID for an Ubuntu image
  }

  metadata = {
    user_data = base64encode(<<EOF
      #cloud-config
      users:
        - name: ubuntu
          lock_passwd: false
          passwd: $6$.UDPfSLNSPQnFe4N$/a7RGpuL2U4VSGfk30Fs07vvMyD9PD/52AM7N1thf5CZzvCecQcsTVQqGB9.1OTcIGUBrxSroDpfE/xGj3dUi1  # Replace with your encrypted password
          sudo: ['ALL=(ALL) NOPASSWD:ALL']
          groups: users, admin
          shell: /bin/bash

      ssh_pwauth: true

      # Enable password authentication in SSHD configuration
      runcmd:
        - sed -i 's/^#PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
        - systemctl restart sshd

        # Install OCI CLI with default parameters
        - curl -sL https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh | bash -s -- --accept-all-defaults

        # Ensure oci command is in the PATH
        - echo 'export PATH=$PATH:/root/bin' >> /etc/profile
        - source /etc/profile

        # Enable Cockpit for web console management (optional)
        - apt update
        - apt install -y cockpit
        - systemctl enable --now cockpit.socket

        # Install kubectl
        - curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        - chmod +x kubectl
        - sudo mv kubectl /usr/local/bin

        # Install helm
        - curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    EOF
    )
  }

  display_name = "bastion-host"
}
