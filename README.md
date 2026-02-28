Hi guys! This is my Color Picker APP project which i wanted to share with you 🐤
Current working app is on (http://3.10.233.51/)

# automation-mvp

Automated deployment of a Dockerised web app on AWS using Terraform, Ansible, and GitHub Actions.

## What it does

- **Terraform** provisions an AWS EC2 instance + security group (SSH 22, HTTP 80) in **eu-west-2**
- **Ansible** installs Docker and enables it on boot
- **Docker** runs a static dark UI color picker site (nginx:alpine)
- **GitHub Actions** redeploys automatically on every push to `main`

## Repo structure

- `infra/` Terraform (EC2 + SG + outputs)
- `ansible/` Ansible playbook (Docker install/enable)
- `app/` `index.html` + `Dockerfile` (nginx static site)
- `.github/workflows/` CI/CD pipeline

## Prerequisites

On your machine (WSL Ubuntu/Linux recommended):
- AWS CLI
- Terraform
- Ansible
- Git
- SSH access (key pair)

AWS:
- An AWS account with IAM credentials that can create EC2 resources
- Region set to **eu-west-2**

## Quick start (fresh machine)

### 1) Clone the repo

```bash
git clone git@github.com:Puram-Prem-Chand/automation-mvp.git
cd automation-mvp
```

### 2) Configure AWS credentials

```bash
aws configure
aws sts get-caller-identity
```

### 3) Create SSH key for EC2

```bash
mkdir -p ~/.ssh
ssh-keygen -t rsa -b 4096 -f ~/.ssh/terraform_key -C "terraform-ec2-key"
```

### 4) Provision infrastructure (Terraform)

```bash
cd infra
export TF_VAR_public_key="$(cat ~/.ssh/terraform_key.pub)"
terraform init
terraform apply -auto-approve
terraform output -raw public_ip
cd ..
```

### 5) Configure server (Ansible)

```bash
./gen_inventory.sh
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml --private-key ~/.ssh/terraform_key
```

### 6) Set GitHub Actions secrets (required for CI/CD)

In GitHub repo → **Settings → Secrets and variables → Actions**, add:

- `SERVER_IP` = `terraform output -raw public_ip`
- `SERVER_USER` = `ubuntu`
- `SSH_PRIVATE_KEY` = contents of `~/.ssh/terraform_key`

Optional CLI method (requires `gh` and login):

```bash
gh auth login
IP=$(cd infra && terraform output -raw public_ip)
gh secret set SERVER_IP -b "$IP" --repo Puram-Prem-Chand/automation-mvp
gh secret set SERVER_USER -b "ubuntu" --repo Puram-Prem-Chand/automation-mvp
gh secret set SSH_PRIVATE_KEY -b "$(cat ~/.ssh/terraform_key)" --repo Puram-Prem-Chand/automation-mvp
```

### 7) Deploy (CI/CD)

Any push to `main` triggers deployment. To force a deploy:

```bash
git commit --allow-empty -m "Trigger deploy"
git push origin main
```

### 8) Verify

```bash
IP=$(cd infra && terraform output -raw public_ip)
echo "http://$IP/"
curl -s "http://$IP/" | head -n 2
```

Open in browser:

- `http://<public-ip>/`

## Common tasks

### View container status on EC2

```bash
IP=$(cd infra && terraform output -raw public_ip)
ssh -i ~/.ssh/terraform_key ubuntu@$IP "docker ps --filter name=project-mvp --no-trunc"
```

### Clean up (destroy AWS resources)

```bash
cd infra
terraform destroy
```

## Notes

- Ensure AWS Console region is **eu-west-2 (London)** to see the EC2 instance.
- Do **not** commit AWS credentials or private keys to the repository.

