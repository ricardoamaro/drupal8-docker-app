# Deploy Drupal8 on Kubernetes

This deployment will setup a Drupal site using Kubernetes. The drupal8-docker-app is not
natively designed to be ran on Kubernetes however it serves the pourpose for testing and development.

## Usage

1 - Spun up a kubernetes cluster

2 - Start the deployment with

```
kubectl apply -f drupal-deployment.yaml
```
