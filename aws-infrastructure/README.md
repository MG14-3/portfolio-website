# AWS Portfolio Website Infrastructure

This directory contains Infrastructure as Code (IaC) templates and deployment scripts for hosting your portfolio website on AWS using S3, CloudFront, CodePipeline, and CodeBuild.

## Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│     GitHub      │    │   CodePipeline  │    │   CodeBuild     │
│   Repository    │───▶│   (CI/CD)       │───▶│   (Build)       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                        │
                                                        ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  CloudFront     │    │   S3 Bucket     │    │   Static Files  │
│   (CDN + SSL)   │◀───│ (Static Hosting)│◀───│   (React Build) │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## AWS Services Used

- **S3**: Static website hosting and artifact storage
- **CloudFront**: CDN for global content delivery and HTTPS
- **CodePipeline**: CI/CD pipeline automation
- **CodeBuild**: Build service for React application
- **IAM**: Security roles and permissions
- **ACM**: SSL certificates for custom domains
- **Route 53**: DNS management (optional)

## Prerequisites

1. **AWS Account**: Active AWS account with appropriate permissions
2. **AWS CLI**: Installed and configured
3. **GitHub Repository**: Your portfolio code pushed to GitHub
4. **GitHub Token**: Personal access token with repo permissions
5. **Domain Name**: Optional, for custom domain setup

### Required GitHub Repository Structure

```
your-portfolio-repo/
├── frontend/           # React application
│   ├── src/
│   ├── public/
│   ├── package.json
│   └── ...
├── buildspec.yml      # CodeBuild configuration
├── aws-infrastructure/ # This directory
└── README.md
```

## Deployment Options

### Option 1: Terraform (Recommended)

**Prerequisites:**
- Install Terraform: https://learn.hashicorp.com/tutorials/terraform/install-cli

**Steps:**
1. Navigate to terraform directory: `cd terraform`
2. Copy example variables: `cp terraform.tfvars.example terraform.tfvars`
3. Edit `terraform.tfvars` with your values
4. Run deployment: `../deploy.sh` and choose option 1

**Terraform Files:**
- `main.tf`: Main infrastructure configuration
- `terraform.tfvars.example`: Example variables file

### Option 2: CloudFormation

**Steps:**
1. Run deployment script: `./deploy.sh`
2. Choose option 2 (CloudFormation)
3. Follow interactive prompts

**CloudFormation Files:**
- `portfolio-infrastructure.yaml`: Complete infrastructure template

## Configuration

### 1. GitHub Personal Access Token

Create a GitHub personal access token with the following permissions:
- `repo` (Full control of private repositories)
- `admin:repo_hook` (Write repository hooks)

**Steps:**
1. Go to GitHub Settings → Developer settings → Personal access tokens
2. Generate new token with required permissions
3. Copy the token securely

### 2. Domain Configuration (Optional)

If you want to use a custom domain:

**For Terraform:**
```hcl
domain_name = "yourportfolio.com"
```

**For CloudFormation:**
- Enter your domain when prompted during deployment

**Additional Steps:**
1. The certificate will be created automatically
2. You'll need to validate the certificate via DNS
3. Update your domain's nameservers to Route 53 (if using)

### 3. Variables Configuration

**Key Variables:**
- `project_name`: Unique identifier for your project
- `github_repo`: Format: `username/repository-name`
- `github_branch`: Usually `main` or `master`
- `github_token`: Your GitHub personal access token
- `aws_region`: AWS region for deployment (default: us-east-1)

## Deployment Process

### Automated Deployment Flow

1. **Source Stage**: CodePipeline pulls code from GitHub
2. **Build Stage**: CodeBuild runs the build process
3. **Deploy Stage**: Built files are uploaded to S3
4. **Invalidation**: CloudFront cache is invalidated

### Build Process (buildspec.yml)

```yaml
phases:
  install:
    - Install Node.js dependencies
  build:
    - Run npm run build
  post_build:
    - Upload to S3
    - Invalidate CloudFront cache
```

## Security Features

- **S3 Bucket**: Private with CloudFront-only access
- **CloudFront**: HTTPS-only with security headers
- **IAM**: Least privilege roles for all services
- **SSL/TLS**: Automatic certificate management via ACM

## Monitoring and Maintenance

### CloudWatch Logs
- CodeBuild logs are automatically sent to CloudWatch
- Monitor build status and errors

### Cost Optimization
- S3 Standard storage class for active files
- CloudFront PriceClass_100 for cost optimization
- CodeBuild uses small compute instances

## Troubleshooting

### Common Issues

1. **Build Fails**: Check CodeBuild logs in CloudWatch
2. **Domain Not Working**: Verify DNS settings and certificate validation
3. **GitHub Connection**: Ensure token has correct permissions
4. **S3 Access**: Check bucket policies and IAM roles

### Useful Commands

```bash
# View CloudFormation stack status
aws cloudformation describe-stacks --stack-name portfolio-website-stack

# View CodePipeline status
aws codepipeline get-pipeline-state --name portfolio-website-pipeline

# Invalidate CloudFront cache manually
aws cloudfront create-invalidation --distribution-id ABCDEFGHIJK --paths "/*"

# View S3 bucket contents
aws s3 ls s3://your-portfolio-bucket/
```

## Cleanup

### Terraform
```bash
cd terraform
terraform destroy
```

### CloudFormation
```bash
aws cloudformation delete-stack --stack-name portfolio-website-stack
```

**Note**: Remember to:
- Delete S3 bucket contents before destroying infrastructure
- Remove any custom domain DNS records
- Revoke GitHub personal access tokens if no longer needed

## Support

If you encounter issues:
1. Check AWS CloudWatch logs
2. Verify GitHub webhook is properly configured
3. Ensure buildspec.yml is in repository root
4. Check IAM permissions for all services

For detailed AWS documentation:
- [S3 Static Website Hosting](https://docs.aws.amazon.com/AmazonS3/latest/dev/WebsiteHosting.html)
- [CloudFront Distribution](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/)
- [CodePipeline User Guide](https://docs.aws.amazon.com/codepipeline/latest/userguide/)
- [CodeBuild User Guide](https://docs.aws.amazon.com/codebuild/latest/userguide/)