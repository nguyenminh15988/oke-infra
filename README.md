# OKE Cluster with Bastion Host and PgSQLAdmin Deployment

This project provides a Terraform configuration for deploying a bastion host and an Oracle Kubernetes Engine (OKE) cluster on Oracle Cloud Infrastructure (OCI). It also includes instructions for deploying a PostgreSQL database with `phpPgAdmin` as a management interface inside the Kubernetes cluster.

## Project Structure

```plaintext
.
├── terraform/                     # Terraform configuration files
│   ├── bastion_host.tf            # Bastion host definition
│   ├── oke_cluster.tf             # OKE cluster and node pool definition
│   ├── variables.tf               # Variables for customizable inputs
│   ├── terraform.tfvar            # input all oci login detail here
│   ├── network.tf                 # Network detail
│   └── provider.tf                # OCI provider configuration
├── oke/                           # Kubernetes deployment configurations
│   ├── PostgreSQL/                # PostgreSQL deployment with TLS enabled
│   │   ├── values.yaml            # Helm values file for PostgreSQL configuration
│   ├── phpPgAdmin/                # PostgreSQL deployment with TLS enabled
│   │   ├── deployments.yaml       # 
│   │   ├── service.yaml           # 
└── README.md                      # 
```

## Infrastructure Setup

The infrastructure includes:
- A **bastion host** running Ubuntu, pre-configured with:
  - **OCI CLI**: To interact with OCI resources.
  - **kubectl**: To manage and interact with the OKE cluster.
  - **helm**: For deploying and managing Kubernetes applications.
- An **OKE cluster** for deploying PostgreSQL and `phpPgAdmin`.

## Prerequisites
- [Oracle Cloud Infrastructure CLI (OCI CLI)](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm) installed and configured on your local machine.
- An OCI account with necessary permissions for managing compute, networking, and Kubernetes resources.
- SSH key pair for accessing the bastion host.

---

## Step 1: Deploy the Infrastructure with Terraform

### 1. Initialize and Apply Terraform

- Clone the repository and navigate to the `terraform/` directory:

  ```bash
  git clone <repository_url>
  cd terraform
  ```

## Set up a `terraform.tfvars` file to define the necessary input variables:

```hcl
compartment_id = "your_compartment_ocid"
availability_domain = "your_availability_domain"
oracle_linux_image_id = "your_image_ocid"
```

## 2. Access the Bastion Host

Use the **Console Connection** feature in OCI to access the bastion host directly:

1. In the OCI Console, navigate to **Compute** > **Instances**.
2. Select your bastion instance.
3. Under **Resources**, click **Console Connections**.
4. Click **Create Console Connection** and follow the instructions to set up access.
5. Once the console connection is ready, click **Launch Console** to open a web-based terminal and access the bastion host.

This method allows direct access to the bastion host without needing an SSH key pair.
password is admin@2025

## 2. Deploy PostgreSQL with Helm

### Create a TLS Certificate and Key for Secure Communication

```bash
mkdir -p oke/PostgreSQL/certs
openssl genrsa -out oke/PostgreSQL/certs/postgresql.key 2048
openssl req -new -key oke/PostgreSQL/certs/postgresql.key -out oke/PostgreSQL/certs/postgresql.csr -subj "/CN=postgresql"
openssl x509 -req -in oke/PostgreSQL/certs/postgresql.csr -signkey oke/PostgreSQL/certs/postgresql.key -out oke/PostgreSQL/certs/postgresql.crt -days 365
kubectl create secret generic postgresql-tls \
  --from-file=oke/PostgreSQL/certs/postgresql.crt \
  --from-file=oke/PostgreSQL/certs/postgresql.key
helm install my-postgres bitnami/postgresql -f oke/PostgreSQL/values.yaml
```


## 3. Deploy phpPgAdmin

### Apply the phpPgAdmin Deployment and Service

```bash
kubectl apply -f oke/phpPgAdmin/deployment.yaml
kubectl apply -f oke/phpPgAdmin/service.yaml
```

## 4. Access phpPgAdmin

### Option 1: Port Forwarding

From the bastion host, forward a local port to access phpPgAdmin internally:

```bash
kubectl port-forward svc/phppgadmin-service 8080:80
```





