locals {
  role_defaults = {
    org               = null
    allow_any_name    = true
    enforce_hostnames = false
    allowed_domains   = []
    allow_subdomains  = false
    server_flag       = false
    client_flag       = true
  }

  k8s_roles_config = {
    "api-server" = {
      allowed_domains   = [
        "kubernetes",
        "kubernetes.default",
        "kubernetes.default.svc",
        "kubernetes.default.svc.cluster.local",
        "localhost"
      ]
      allow_subdomains  = true
      server_flag       = true
    }

    "admin" = {
      org = "system:masters"
      allow_any_name   = false
      enforce_hostnames = true
    }

    "worker" = {
      org               = "system:nodes"
      allow_subdomains  = true
      allowed_domains   = ["internal"] 
      server_flag       = true
    }

    "kube-proxy" = {
      org = "system:node-proxier"
      allowed_domains   = ["kube-proxy"]
      server_flag       = true
    }

    "kube-controller-manager" = {
      org = "system:kube-controller-manager"
      allowed_domains   = ["kube-controller-manager"]
      server_flag       = true
    }

    "kube-scheduler" = {
      org = "system:kube-scheduler"
      allowed_domains   = ["kube-scheduler"]
      server_flag       = true
    }
    
    "service-accounts" = {
      org = "" 
      allow_any_name   = false
      enforce_hostnames = true
    }
  }
}
