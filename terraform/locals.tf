locals {
  role_defaults = {
    org               = null
    allow_any_name    = false
    enforce_hostnames = false
    allowed_domains   = []
    allow_subdomains  = false
    allow_bare_domains = true
    server_flag       = false
    client_flag       = true
  }

  k8s_roles_config = {
    "api-server" = {
      allowed_domains   = [
        "kubernetes",
        "kubernetes.default",
        "kubernetes.default.svc",
        "kubernetes.default.svc.cluster",
        "kubernetes.svc.cluster.local",
        "server.kubernetes.local",
        "api-server.kubernetes.local",
        "localhost"
      ]
      allow_subdomains  = true
      server_flag       = true
    }

    "admin" = {
      org = "system:masters"
      allowed_domains   = ["kubernetes-super-admin"]
    }

    "worker" = {
      org               = "system:nodes"
      allow_any_name    = true
      server_flag       = true
    }

    "kube-proxy" = {
      org = "system:node-proxier"
      allowed_domains   = ["system:kube-proxy", "kube-proxy"]
      server_flag       = true
    }

    "kube-controller-manager" = {
      org = "system:kube-controller-manager"
      allowed_domains   = ["system:kube-controller-manager", "kube-controller-manager"]
      server_flag       = true
    }

    "kube-scheduler" = {
      org = "system:system:kube-scheduler"
      allowed_domains   = ["system:kube-scheduler", "kube-scheduler"]
      server_flag       = true
    }
    
    "service-accounts" = {
      org = "kubernetes-service-accounts" 
      allowed_domains   = ["service-accounts"]
    }
  }
}
