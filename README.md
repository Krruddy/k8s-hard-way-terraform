# Kubernetes The Hard Way (IaC Edition)

![Terraform](https://img.shields.io/badge/IaC-Terraform-623CE4?&logo=terraform)
![Ansible](https://img.shields.io/badge/Config-Ansible-EE0000?&logo=ansible&logoColor=white)
![Vault](https://img.shields.io/badge/Secrets-HashiCorp%20Vault-000000?&logo=vault)
![Kubernetes](https://img.shields.io/badge/Orchestration-Kubernetes-326CE5?&logo=kubernetes)

> **A security-first implementation of the classic "Kubernetes The Hard Way" tutorial, engineered for the modern cloud Platform stack.**

## 📋 Project Overview

This repository contains the Infrastructure as Code (IaC) to bootstrap a Kubernetes cluster from scratch on **Proxmox VE**. 

Unlike the original guide which relies on manual shell commands and static files, this project implements a **secure** architecture. It leverages **Terraform** for state management and **HashiCorp Vault** for dynamic secret injection, ensuring that no sensitive credentials (SSH keys, API tokens, TLS certificates) are ever hardcoded in the codebase.

## 🏗 Architecture & Trust Flow

The system uses a strict "Chain of Trust" to provision infrastructure without leaking secrets.

```mermaid
sequenceDiagram
    participant User as Me (GPG/Pass)
    participant TF as Terraform (Local)
    participant Vault as HashiCorp Vault
    participant PVE as Proxmox VE
    participant VM as K8s Node (VM)

    Note over User, TF: Phase 1: Secure Auth
    User->>TF: Unlocks Local Secrets (RoleID + SecretID)
    TF->>Vault: Login with AppRole (Push Mode)
    Vault-->>TF: Returns Short-Lived Token

    Note over TF, PVE: Phase 2: Infrastructure Provisioning
    TF->>Vault: Request Proxmox API Token (KV Engine)
    Vault-->>TF: Returns Token
    TF->>PVE: Authenticate & Provision VM
    PVE-->>VM: Boot VM

    Note over TF, VM: Phase 3: Bootstrap (Future)
    TF->>Vault: Request Wrapped SecretID (Pull Mode)
    Vault-->>TF: Returns Wrapping Token (Time-Bombed)
    TF->>VM: Inject Wrapping Token (Cloud-Init)
    VM->>Vault: Unwrap Token
    Vault-->>VM: Returns SecretID
    VM->>Vault: Login & Fetch Certificates
```

## 🔐 Key Features (so far)

### Security

I implemented a **Zero Trust** Secret Management workflow:

- **Eliminated implicit trust:** Replaced hardcoded credentials with dynamic, identity-based authentication using **Vault AppRole**.
- **Enforced Least Privilege:** Scoped Terraform's access using granular Vault policies, ensuring it can only read specific infrastructure secrets.
- **Secured the 'Secret Zero':** Protected initial bootstrap credentials using **offline** encryption (GPG/Pass) rather than plain-text environment variables.

### Automation

- **Terraform:** Provisions the underlying infrastructure (Compute, Networking, ...) on Proxmox and configures Vault AppRoles.
- **Ansible:** (Planned) Bootstraps the Kubernetes control plane, installs container runtimes (containerd), and manages OS-level configuration, replacing manual scp and ssh loops.
