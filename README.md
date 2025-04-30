# Terraform Infrastructure for EKS and ECR

This repository contains Terraform modules for creating an Amazon EKS (Kubernetes) cluster and ECR (Elastic Container Registry) repositories.

## Directory Structure

```bash
terraform/
├── deploy/
│   ├── ecr/          # Root module for ECR deployment
│   └── eks/          # Root module for EKS deployment
│
├── modules/
│   ├── ecr/          # ECR module
│   └── eks-cluster/  # EKS module
```

## Trade-offs and Limitations

<details>
<summary>Click to expand</summary>

### EKS Cluster Trade-offs:

1. **Security**:
   - Public API Access
   - No Network Policies
   - No TLS for Ingress
   - Basic Authentication without MFA

2. **Cost vs Redundancy**:
   - Only 2 Availability Zones
   - Single NAT Gateway
   - Limited CloudWatch Logging

3. **Infrastructure**:
   - Medium Instance Size
   - Simplified VPC
   - No Transit Gateway
   - Public Endpoint Only
   - Node auto scaling is not implemented yet
   - No Node Termination Protection
   
4. **Management**:
   - Minimal Cluster Add-ons
   - Manual Kubernetes Version Updates
   - No Blue/Green Cluster Upgrades

### ECR Registry Trade-offs:

1. **Security**:
   - Broad Access Controls
   - No Cross-Region Replication

2. **Scalability**:
   - No Cross-Account Access

</details>

---

## Security Considerations for Production

- Enable Private Endpoint Access to EKS
- Implement Network Policies 
- Use IAM Roles for Service Accounts (IRSA)
- Setup Logging and Monitoring (Prometheus/Grafana)
- Use Image Tag Immutability for ECR

---

## Argo CD Setup

Access is secured via basic authentication.  
The Argo CD dashboard can be accessed via **port forwarding**:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Then access Argo CD UI at: [https://localhost:8080](https://localhost:8080)

Default credentials are configured for the demo environment.

