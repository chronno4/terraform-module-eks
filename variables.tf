variable "vpc_id" {
  type        = string
  description = "The VPC identification where the new EKS will be deployed"
}

variable "subnet_ids" {
  type        = list(any)
  description = "The subnets identification where the new EKS will be deployed"
}

variable "cluster_name" {
  type        = string
  description = "The name of the cluster"
}

variable "mapped_roles" {
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  description = "A map of roles to be attached to the EKS"
  default     = []
}

variable "cluster_endpoint_private_access" {
  type        = bool
  description = "Set if the Amazon EKS private API server is enabled"
  default     = true
}

variable "cluster_endpoint_public_access" {
  type        = bool
  description = "Set if the Amazon EKS public API server is enabled"
  default     = false
}

variable "worker_nodes" {
  type = map(object({
    min_size       = number
    max_size       = number
    desired_size   = number
    instance_types = list(string)
    labels         = optional(map(string), {})
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
    tags = optional(map(string), {})
  }))
  description = "A Map with all nodes definitions to be used. As result, will be created a node group with defined settings"
  default = {
    ONDEMAND = {
      min_size       = 1
      max_size       = 10
      desired_size   = 1
      instance_types = ["t3.large"]
      labels         = {}
      taints         = []
      tags           = {}
    }
  }
}


variable "default_kubernetes_version" {
  type        = string
  description = "Default Kubernetes version to be used in the installation"
  default     = "1.30"
}

variable "enable_csi_driver_ebs" {
  type        = bool
  description = "Set if the EBS CSI driver will be deployed in the cluster"
  default     = false

}
variable "enable_csi_driver_efs" {
  type        = bool
  description = "Set if the EFS CSI driver will be deployed in the cluster"
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to add to all resources"
  default     = {}
}

#Autoscaling options
variable "autoscaling_controller_expander" {
  type        = string
  description = "Autoscaling expander. Check the [documentation](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#what-are-expanders) to see possible combinations"
  default     = "random"
}

variable "autoscaling_controller_expander_priorities" {
  type        = string
  description = "Autoscaling priorities to be used if autoscaling_controller_expander contains priority"
  default     = ""
}


variable "log_retention_in_days" {
  type        = number
  description = "Number of days to retain log events"
  default     = 14
}

variable "custom_cluster_addons" {
  type        = map(any)
  description = "Allows customize which cluster addons to use"
}

variable "kms_key_administrators" {
  description = "A list of IAM ARNs for [key administrators](https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-default-allow-administrators). If no value is provided, the current caller identity is used to ensure at least one key admin is available"
  type        = list(string)
  default     = []
}

variable "install_nginx_ingress" {
  description = "Flag to install NGINX Ingress with NLB"
  type        = bool
  default     = false
}

variable "fullname_override" {
  description = "Override the full name for the NGINX Ingress"
  type        = string
  default     = "ingress-nginx-nlb-default"
}

variable "ingress_class_resource_name" {
  description = "Name of the ingress class resource"
  type        = string
  default     = "nginx-nlb-default"
}

variable "ingress_class_resource_controller_value" {
  description = "Controller value for the ingress class resource"
  type        = string
  default     = "k8s.io/ingress-nginx-nlb-default"
}

variable "ingress_class" {
  description = "Ingress class for the NGINX Ingress"
  type        = string
  default     = "nginx-nlb-default"
}

variable "aws_lb_ssl_cert_arn" {
  description = "ARN of the SSL certificate for the AWS Load Balancer"
  type        = string
  default     = ""
}

variable "external_dns_target" {
  description = "External DNS target for the NGINX Ingress"
  type        = string
  default     = "external-dns"
}

variable "nginx_ingress_version" {
  description = "Version of the NGINX Ingress"
  type        = string
  default     = "4.11.1"
}

### External Secret

### External Secrets
variable "external_secret_chart_version" {
  description = "External Secrets chart version."
  type        = string
  default     = "0.9.20"
}

variable "external_secrets_namespace" {
  description = "Namespace for External Secrets resources like ServiceAccount and ClusterSecretStore."
  type        = string
  default     = "kube-system"
}

variable "external_secret_name" {
  description = "The name of the ExternalSecret resource."
  type        = string
  default     = "external_secret"
}

variable "secret_store_name" {
  description = "The name of the ClusterSecretStore resource."
  type        = string
  default     = "aws-secrets-manager"
}

variable "external_secret_target_namespace" {
  description = "The namespace where the ExternalSecret resource will be created."
  type        = string
  default     = "kube-system"
}

variable "secret_data" {
  description = "The data for the ExternalSecret."
  type = list(object({
    secretKey = string
    remoteKey = string
    property  = string
  }))
}

variable "external_secret_refresh_interval" {
  description = "Refresh interval for the ExternalSecret resource."
  type        = string
  default     = "1h"
}

variable "service_account_name" {
  description = "The name of the ServiceAccount used for authentication."
  type        = string
  default     = "external-secrets-sa"
}

variable "docker_secret_name" {
  description = "The name of the ExternalSecret resource for Docker registry."
  type        = string
  default     = "docker-registry-secret"
}

variable "docker_secret_namespace" {
  description = "The namespace where the Docker ExternalSecret will be created."
  type        = string
  default     = "default"
}


variable "docker_remote_key" {
  description = "The remote key in the secret store for the Docker config JSON."
  type        = string
  default     = "your-secrets-manager-key"
}
variable "argocd_name" {
  description = "Name of ArgoCD"
  type        = string
  default     = "argocd"
}

variable "argocd_chart_version" {
  description = "Version of ArgoCD chart"
  type        = string
  default     = "7.3.11"
}

variable "argocd_namespace" {
  description = "Namespace for ArgoCD"
  type        = string
  default     = "argocd"
}

variable "argocd_ingress_hostname" {
  description = "Ingress hostname for ArgoCD"
  type        = string
}

variable "argocd_path" {
  description = "Ingress path for ArgoCD"
  type        = string
}

variable "ingressclassname" {
  description = "Ingress class name for ArgoCD"
  type        = string
  default     = "alb"
}

variable "argocd_repositories" {
  description = "ArgoCD repositories"
  type = map(object({
    url      = string
    name     = string
    password = string
    username = string
  }))
  default = {}
}

variable "argocd_projects" {
  description = "List of ArgoCD projects"
  type = map(object({
    name        = string
    description = string
  }))
  default = {}
}

variable "applicationset_ingress_hostname" {
  description = "Ingress hostname for ApplicationSet of ArgoCD"
  type        = string
}

variable "applicationset_path" {
  description = "Ingress path for ApplicationSet of ArgoCD"
  type        = string
}

variable "install_argocd" {
  description = "Flag to control the installation of ArgoCD"
  type        = bool
  default     = true
}
