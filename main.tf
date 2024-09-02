locals {
  compound_cluster_name = "${var.cluster_name}-cluster"
  key_pair_name         = "${var.cluster_name}-eks-openssh-private-key-${random_string.random_suffix.result}"

  cidr_block           = data.aws_vpc.current.cidr_block
  oidc_provider_arn    = module.eks.oidc_provider_arn
  oidc_provider_issuer = module.eks.oidc_provider
}

data "aws_vpc" "current" {
  id = var.vpc_id
}

resource "random_string" "random_suffix" {
  length  = 5
  special = false
  upper   = false
}

module "key_pair" {
  source = "git::ssh://git@stash.matera.com:7999/trm/aws-key-pair.git?ref=main"

  secret_name = local.key_pair_name
}

module "eks" {
  ### Related to external module
  ## https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest
  source  = "terraform-aws-modules/eks/aws"
  version = "19.21.0"
  ###

  ### Network related configuration
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  ### Misc configuration
  cluster_name              = local.compound_cluster_name
  cluster_version           = var.default_kubernetes_version
  manage_aws_auth_configmap = false
  enable_irsa               = true

  cluster_enabled_log_types = ["api", "authenticator", "audit", "scheduler", "controllerManager"]

  cluster_addons = try(var.custom_cluster_addons,
    {
      coredns = {
        most_recent = true
      }
      kube-proxy = {
        most_recent = true
      }
      vpc-cni = {
        most_recent = true
      }
    },
    var.enable_csi_driver_efs ? {
      aws-efs-csi-driver = {
        most_recent = true
      }
    } : {}
  )

  ### Authentication and Authorization settings
  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access

  cluster_security_group_additional_rules = {
    access_from_vpn = {
      description                = "Enable access from VPN"
      protocol                   = "tcp"
      cidr_blocks                = ["10.0.0.0/8"]
      from_port                  = 443
      to_port                    = 443
      type                       = "ingress"
      source_node_security_group = false
    }
  }
  ### Compute related settings
  eks_managed_node_group_defaults = {
    key_name = module.key_pair.secret_name
    security_group_rules = {
      vpcIn = {
        protocol    = "tcp"
        from_port   = 0
        to_port     = 65535
        type        = "ingress"
        cidr_blocks = local.cidr_block
      }
      allOut = {
        protocol    = "tcp"
        from_port   = 0
        to_port     = 65535
        type        = "egress"
        cidr_blocks = ["0.0.0.0/0"]
      }
    }

    block_device_mappings = {
      xvda = {
        device_name = "/dev/xvda"
        ebs = {
          volume_size = 20
          volume_type = "gp3"
        }
      }
    }

    iam_role_additional_policies = {
      AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    }

    tags = {
      "k8s.io/cluster-autoscaler/${local.compound_cluster_name}" = "owned"
      "k8s.io/cluster-autoscaler/enabled"                        = "true"
    }
  }

  eks_managed_node_groups = var.worker_nodes

  cloudwatch_log_group_retention_in_days = var.log_retention_in_days

  kms_key_administrators = var.kms_key_administrators

  tags = var.tags
}

module "eks_aws_auth" {
  source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version = "~> 20.0"

  manage_aws_auth_configmap = false
}

data "aws_eks_cluster_auth" "this" {
  name = local.compound_cluster_name
}

module "eks_addons" {
  source = "git::ssh://git@github.com:chronno4/exemplo-addon-eks.git?ref=main"

  auth_mapping          = var.mapped_roles
  cluster_name          = module.eks.cluster_name
  cluster_auth_endpoint = module.eks.cluster_endpoint
  cluster_auth_ca       = module.eks.cluster_certificate_authority_data
  cluster_auth_token    = data.aws_eks_cluster_auth.this.token

  enable_csi_driver_ebs = var.enable_csi_driver_ebs
  enable_csi_driver_efs = var.enable_csi_driver_efs

  oidc_provider_arn    = local.oidc_provider_arn
  oidc_provider_issuer = local.oidc_provider_issuer

  autoscaling_controller_expander            = var.autoscaling_controller_expander
  autoscaling_controller_expander_priorities = var.autoscaling_controller_expander_priorities

  # External Secrets
  external_secret_chart_version    = var.external_secret_chart_version
  external_secrets_namespace       = var.external_secrets_namespace
  external_secret_name             = var.external_secret_name
  secret_store_name                = var.secret_store_name
  external_secret_target_namespace = var.external_secret_target_namespace
  secret_data                      = var.secret_data
  external_secret_refresh_interval = var.external_secret_refresh_interval
  service_account_name             = var.service_account_name
  docker_secret_name               = var.docker_secret_name
  docker_secret_namespace          = var.docker_secret_namespace
  docker_remote_key                = var.docker_remote_key


  # Nginx Ingress
  install_nginx_ingress                   = var.install_nginx_ingress
  fullname_override                       = var.fullname_override
  ingress_class_resource_name             = var.ingress_class_resource_name
  ingress_class_resource_controller_value = var.ingress_class_resource_controller_value
  ingress_class                           = var.ingress_class
  aws_lb_ssl_cert_arn                     = var.aws_lb_ssl_cert_arn
  external_dns_target                     = var.external_dns_target
  nginx_ingress_version                   = var.nginx_ingress_version


  # Argocd
  argocd_name                     = var.argocd_name
  argocd_chart_version            = var.argocd_chart_version
  argocd_namespace                = var.argocd_namespace
  argocd_ingress_hostname         = var.argocd_ingress_hostname
  argocd_path                     = var.argocd_path
  ingressclassname                = var.ingressclassname
  applicationset_ingress_hostname = var.applicationset_ingress_hostname
  applicationset_path             = var.applicationset_path
  argocd_repositories             = var.argocd_repositories
  argocd_projects                 = var.argocd_projects
}


