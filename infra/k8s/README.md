# Medecin Africa Kubernetes Deployment

This directory contains Kubernetes configuration files for deploying the Medecin Africa application.

## Directory Structure

```
infra/k8s/
├── backend/               # Django backend deployment and service
│   └── deployment.yaml
├── frontend/              # Next.js frontend deployment and service
│   └── deployment.yaml
├── postgres/              # PostgreSQL StatefulSet and service
│   └── statefulset.yaml
├── redis/                 # Redis deployment and service
│   └── deployment.yaml
├── elasticsearch/         # Elasticsearch configuration (TBD)
├── kibana/                # Kibana configuration (TBD)
├── ingress/               # Ingress configuration
│   └── ingress.yaml
└── secrets/               # Kubernetes secrets (DO NOT commit actual secrets)
    └── template.yaml     # Template for creating secrets
```

## Prerequisites

1. A running Kubernetes cluster (e.g., EKS, GKE, AKS, or minikube)
2. `kubectl` configured to communicate with your cluster
3. `helm` (for installing cert-manager and ingress-nginx)
4. A container registry (Docker Hub, ECR, GCR, etc.)

## Setup Instructions

### 1. Create the namespace

```bash
kubectl create namespace medecin-africa
```

### 2. Set up Secrets

1. Copy the template file:
   ```bash
   cp secrets/template.yaml secrets/secrets.yaml
   ```

2. Edit `secrets/secrets.yaml` and replace all placeholder values with actual base64-encoded values:
   ```bash
   echo -n "your-secret-value" | base64
   ```

3. Apply the secrets:
   ```bash
   kubectl apply -f secrets/secrets.yaml
   ```

### 3. Deploy Dependencies

```bash
# PostgreSQL
kubectl apply -f postgres/statefulset.yaml

# Redis
kubectl apply -f redis/deployment.yaml
```

### 4. Deploy Applications

```bash
# Backend (Django)
kubectl apply -f backend/deployment.yaml

# Frontend (Next.js)
kubectl apply -f frontend/deployment.yaml
```

### 5. Set up Ingress

1. Install the NGINX Ingress Controller (if not already installed):
   ```bash
   helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
   helm install nginx-ingress ingress-nginx/ingress-nginx \
     --namespace ingress-nginx \
     --create-namespace \
     --set controller.publishService.enabled=true
   ```

2. Install cert-manager for TLS certificates:
   ```bash
   kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
   kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.crds.yaml
   ```

3. Create a ClusterIssuer for Let's Encrypt:
   ```yaml
   # cert-issuer.yaml
   apiVersion: cert-manager.io/v1
   kind: ClusterIssuer
   metadata:
     name: letsencrypt-prod
   spec:
     acme:
       server: https://acme-v02.api.letsencrypt.org/directory
       email: your-email@example.com
       privateKeySecretRef:
         name: letsencrypt-prod
       solvers:
       - http01:
           ingress:
             class: nginx
   ```
   ```bash
   kubectl apply -f cert-issuer.yaml -n medecin-africa
   ```

4. Apply the Ingress configuration:
   ```bash
   kubectl apply -f ingress/ingress.yaml
   ```

### 6. Verify Installation

Check the status of all resources:

```bash
kubectl get all -n medecin-africa
```

Check the status of the Ingress:

```bash
kubectl get ingress -n medecin-africa
```

## CI/CD Integration

For CI/CD, you'll need to:

1. Build and push your Docker images in your CI pipeline
2. Update the image tags in the deployment files
3. Apply the updated configurations using `kubectl apply -f <directory>`

## Monitoring and Logging

Consider setting up monitoring and logging solutions like:

- Prometheus and Grafana for monitoring
- ELK Stack or Loki for logging
- Kubernetes Dashboard for cluster management

## Troubleshooting

- Check pod logs: `kubectl logs <pod-name> -n medecin-africa`
- Describe a pod: `kubectl describe pod <pod-name> -n medecin-africa`
- Get shell access to a pod: `kubectl exec -it <pod-name> -n medecin-africa -- /bin/bash`
- View events: `kubectl get events -n medecin-africa`
