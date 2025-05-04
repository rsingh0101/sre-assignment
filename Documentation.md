## Documentation
Major settings for setup is located in ```cluster-start.sh``` script


1. Cluster Setup:
Kind cluster created with control-plane and worker nodes.
Port mappings for ingress set up (ports 30000 and 30001).

1. Ingress Controller:
Deployed and configured nginx ingress with the necessary ports.
Ingress resources are now available for routing traffic.

1. CoreDNS Configuration:
Custom CoreDNS configuration has been applied to the cluster, allowing dynamic addition of node IPs to the DNS records.

1. Argo CD:
Installed and set up Argo CD with the metrics-app deployment.
Successfully synced the metrics-app from the Git repository and rolled out the necessary resources, including namespaces, services, deployments, and ingress.

1. Accessing Argo CD:
The password for logging into Argo CD is provided, and you can access the UI through the URL http://argocd.mykubernetescluster.com:30000/.