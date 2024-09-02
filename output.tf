output "cluster_name" {
  value       = module.eks.cluster_name
  description = "The created cluster name"
}

output "cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "Endpoint for your Kubernetes API server"
}

output "cluster_auth_ca" {
  value       = module.eks.cluster_certificate_authority_data
  description = "Base64 encoded certificate data required to communicate with the cluster"
}

output "cluster_auth_token" {
  sensitive   = true
  value       = data.aws_eks_cluster_auth.this.token
  description = "Token to use to authenticate with the cluster"
}

output "asg_names" {
  value       = module.eks.eks_managed_node_groups_autoscaling_group_names
  description = "List of the autoscaling group names created by EKS managed node groups"
}

