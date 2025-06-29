
# AWS Account & Region Replication Guide
This guide describes how to replicate our production infrastructure (blue, ap‑south‑1) into a new yellow environment in the us‑east‑1 account (for testing and US production).  
<br>

## 1. Prerequisites
- AWS CLI configured with access to both accounts (India prod & US).  
- Terraform v1.2+ installed.  
- Existing Terraform modules in local.  
- Permissions to create ACM certificates, S3 buckets, Route 53 records.  
<br>

## 2. Files & Variables Layout
Create environment specific tfvars and backend tfvars for us-east-1 as shown:
```
.
├── modules/
│   └── … your reusable modules …
├── provisoners/
│   ├── tfvars/
│   │   ├── blue_apsouth1/
│   │   │   ├── backend.tfvars
│   │   │   └── blue.tfvars
│   │   └── yellow_useast1/
│   │       ├── backend.tfvars
│   │       └── yellow.tfvars
│   └── main.tf
```
<br>

### 2.1 `backend.tfvars` (yellow_useast1)
```hcl
bucket = "svalgo-terraform-yellow-backend"
key    = "aws/yellow/us-east-1/yellow.tfstate"
```
<br>

### 2.2 `yellow.tfvars`
```hcl
vpc_name             = "yellow"
vpc_cidr             = "11.0.0.0/16"
public_subnet_cidrs  = ["11.0.1.0/24", "11.0.2.0/24"]
private_subnet_cidrs = ["11.0.4.0/24", "11.0.5.0/24"]
environment          = "yellow"
databse_name         = "dev"
db_instance_class    = "db.t3.medium"
database_identifier  = "algocore"
billing_mode         = "PAY_PER_REQUEST"
hash_key             = "tenant_id"
hash_key_datatype    = "S"
ecs_cluster_name     = "tfalgo"
ssl_cert_arn         = "arn:aws:acm:us-east-1:850223867483:certificate/32d0c73d-a2e5-4ace-af88-f8cfdeb68755"
global_ssl_cert_arn  = "arn:aws:acm:us-east-1:850223867483:certificate/32d0c73d-a2e5-4ace-af88-f8cfdeb68755"
tags = {
  "Environment" = "yellow"
}
```
<br>

## 3. DNS Setup

### 3.1 Hosted Zone
We use the existing `svalgotech.com` hosted zone in the India account. Add a delegated sub‑zone:  
<br>

| Name                    | Type | Value                                                                                                     |
|-------------------------|------|-----------------------------------------------------------------------------------------------------------|
| yellow.svalgotech.com   | NS   | ns-1900.awsdns-45.co.uk, ns-651.awsdns-17.net, ns-1357.awsdns-41.org, ns-445.awsdns-55.com                |
<br>

### 3.2 Certificate
In us‑east‑1, issue or create a certificate via ACM:  <br>
aws acm request-certificate    
--domain-name yellow.svalgotech.com   
--subject-alternative-names '*.yellow.svalgotech.com'   
--region us-east-1   
--validation-method DNS


Once validated, note the ARN:  
`arn:aws:acm:us-east-1:850223867483:certificate/32d0c73d-a2e5-4ace-af88-f8cfdeb68755`  
<br>

## 4. Terraform Backend (S3)

Create your S3 bucket in us‑east‑1:  <br>
--bucket svalgo-terraform-yellow-backend   
--region us-east-1   
--create-bucket-configuration 
LocationConstraint=us-east-1

Enable versioning :    
--bucket svalgo-terraform-yellow-backend   
--versioning-configuration Status=Enabled

<br>

## 5. Deployment Steps

From the `provisoners/` directory:  
<br>

### Initialize Terraform
```bash
terraform init -backend-config="./tfvars/yellow_useast1/backend.tfvars"
```

### Review Plan
```bash
terraform plan -var-file="./tfvars/yellow_useast1/yellow.tfvars"
```

### Apply
```bash
terraform apply -var-file="./tfvars/yellow_useast1/yellow.tfvars"
```

---
