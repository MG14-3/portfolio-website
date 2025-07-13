# Step-by-Step AWS Deployment Guide

This guide walks you through deploying your portfolio website to AWS with complete CI/CD automation.

## 🚀 Quick Start (5 Minutes)

### Prerequisites Checklist
- [ ] AWS account with programmatic access
- [ ] GitHub repository with your portfolio code
- [ ] GitHub personal access token
- [ ] AWS CLI installed and configured
- [ ] Domain name (optional)

### Rapid Deployment

1. **Clone and Setup**
   ```bash
   git clone <your-repo>
   cd <your-repo>/aws-infrastructure
   chmod +x deploy.sh
   ```

2. **Run Deployment**
   ```bash
   ./deploy.sh
   ```

3. **Choose Option 2** (CloudFormation - easier for beginners)

4. **Follow Interactive Prompts**
   - Enter project name
   - Enter GitHub repo (format: username/repo)
   - Enter GitHub token
   - Wait for deployment (~5-10 minutes)

5. **Access Your Website**
   - CloudFront URL will be provided in outputs
   - Your site is now live with HTTPS and global CDN!

---

## 📋 Detailed Step-by-Step Guide

### Step 1: Prepare Your Repository

1. **Repository Structure**
   ```
   your-portfolio/
   ├── frontend/           # Your React app
   │   ├── src/
   │   ├── public/
   │   ├── package.json
   │   └── ...
   ├── buildspec.yml      # Build configuration
   ├── aws-infrastructure/ # Deployment files
   └── README.md
   ```

2. **Ensure buildspec.yml is in root**
   ```bash
   # Copy the buildspec.yml to your repository root
   cp buildspec.yml ../
   ```

3. **Push to GitHub**
   ```bash
   git add .
   git commit -m "Add AWS deployment infrastructure"
   git push origin main
   ```

### Step 2: Create GitHub Personal Access Token

1. **Go to GitHub Settings**
   - Navigate to Settings → Developer settings → Personal access tokens
   - Click "Generate new token"

2. **Configure Token Permissions**
   - Select expiration (recommend 90 days)
   - Check these permissions:
     - `repo` (Full control of private repositories)
     - `admin:repo_hook` (Write repository hooks)

3. **Save Token Securely**
   ```bash
   # Store in a secure location - you'll need it for deployment
   export GITHUB_TOKEN="your_token_here"
   ```

### Step 3: Configure AWS CLI

1. **Install AWS CLI**
   ```bash
   # macOS
   brew install awscli
   
   # Linux
   curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
   unzip awscliv2.zip
   sudo ./aws/install
   
   # Windows
   # Download from https://awscli.amazonaws.com/AWSCLIV2.msi
   ```

2. **Configure AWS Credentials**
   ```bash
   aws configure
   ```
   Enter:
   - AWS Access Key ID
   - AWS Secret Access Key
   - Default region: `us-east-1`
   - Default output format: `json`

3. **Test Configuration**
   ```bash
   aws sts get-caller-identity
   ```

### Step 4: Deploy Infrastructure

#### Option A: Using CloudFormation (Recommended for Beginners)

1. **Run Deployment Script**
   ```bash
   cd aws-infrastructure
   ./deploy.sh
   ```

2. **Select Option 2** (CloudFormation)

3. **Provide Required Information**
   ```
   Project name: my-portfolio
   Domain name: myportfolio.com (optional)
   GitHub repo: username/portfolio-repo
   GitHub branch: main
   GitHub token: [paste your token]
   ```

4. **Monitor Deployment**
   - CloudFormation stack creation takes 5-10 minutes
   - Watch the console output for progress
   - Check AWS Console → CloudFormation for detailed status

#### Option B: Using Terraform (Advanced Users)

1. **Install Terraform**
   ```bash
   # macOS
   brew install terraform
   
   # Linux
   wget https://releases.hashicorp.com/terraform/1.0.0/terraform_1.0.0_linux_amd64.zip
   unzip terraform_1.0.0_linux_amd64.zip
   sudo mv terraform /usr/local/bin/
   ```

2. **Configure Variables**
   ```bash
   cd terraform
   cp terraform.tfvars.example terraform.tfvars
   nano terraform.tfvars  # Edit with your values
   ```

3. **Deploy**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

### Step 5: Verify Deployment

1. **Check Outputs**
   - CloudFront Distribution URL
   - S3 Bucket Name
   - CodePipeline Name

2. **Test Website**
   ```bash
   # Open the CloudFront URL in browser
   open https://d1234567890abc.cloudfront.net
   ```

3. **Verify CI/CD Pipeline**
   - Make a small change to your React app
   - Push to GitHub
   - Watch CodePipeline automatically build and deploy

### Step 6: Custom Domain Setup (Optional)

1. **Certificate Validation**
   - If you provided a domain, ACM certificate was created
   - Check AWS Certificate Manager console
   - Add DNS validation records to your domain

2. **DNS Configuration**
   - Update your domain's DNS to point to CloudFront
   - Add CNAME record: `www.yourdomain.com` → `d1234567890abc.cloudfront.net`
   - Add A record for root domain (if using Route 53)

3. **Wait for Propagation**
   - DNS changes can take up to 48 hours
   - Test with: `dig yourdomain.com`

---

## 🔧 Configuration Options

### Environment Variables for CodeBuild

Add these to your buildspec.yml if needed:

```yaml
environment:
  variables:
    NODE_ENV: production
    REACT_APP_API_URL: https://api.yourdomain.com
    GENERATE_SOURCEMAP: false
```

### Custom Build Commands

Modify buildspec.yml for your specific needs:

```yaml
phases:
  install:
    runtime-versions:
      nodejs: 18
    commands:
      - cd frontend
      - npm ci --only=production
      
  build:
    commands:
      - npm run build
      - npm run test:ci  # Add tests
      
  post_build:
    commands:
      - aws s3 sync build/ s3://$S3_BUCKET --delete
      - aws cloudfront create-invalidation --distribution-id $CLOUDFRONT_DISTRIBUTION_ID --paths "/*"
```

### Security Headers

Add security headers to CloudFront:

```yaml
# In CloudFormation template
ResponseHeadersPolicyId: 67f7725c-6f97-4210-82d7-5512b31e9d03  # AWS Managed Security Headers
```

---

## 🐛 Troubleshooting

### Common Issues and Solutions

1. **Build Fails with "npm command not found"**
   ```yaml
   # In buildspec.yml, ensure correct Node.js version
   install:
     runtime-versions:
       nodejs: 18
   ```

2. **GitHub Connection Failed**
   ```bash
   # Check token permissions
   curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user
   ```

3. **S3 Access Denied**
   ```bash
   # Check IAM roles in AWS Console
   # Ensure CodeBuild role has S3 permissions
   ```

4. **CloudFront Cache Issues**
   ```bash
   # Manual cache invalidation
   aws cloudfront create-invalidation --distribution-id YOUR_DISTRIBUTION_ID --paths "/*"
   ```

5. **Domain Not Resolving**
   ```bash
   # Check DNS propagation
   dig yourdomain.com
   nslookup yourdomain.com
   ```

### Debugging Commands

```bash
# View build logs
aws logs describe-log-groups --log-group-name-prefix "/aws/codebuild/"

# Check pipeline status
aws codepipeline get-pipeline-state --name your-pipeline-name

# View CloudFormation events
aws cloudformation describe-stack-events --stack-name your-stack-name
```

---

## 💰 Cost Estimation

### Monthly Costs (USD)

- **S3 Storage**: $0.02 per GB (typical portfolio: $0.01)
- **CloudFront**: $0.085 per GB transferred (first 1TB free)
- **CodeBuild**: $0.005 per build minute (100 minutes free)
- **CodePipeline**: $1.00 per active pipeline
- **Route 53**: $0.50 per hosted zone (if using custom domain)

**Estimated Monthly Cost**: $1.50 - $3.00 for typical usage

### Cost Optimization Tips

1. **Use S3 Intelligent Tiering** for older files
2. **Enable CloudFront compression**
3. **Optimize build time** to reduce CodeBuild costs
4. **Use PriceClass_100** for CloudFront (included in template)

---

## 📊 Monitoring and Maintenance

### CloudWatch Dashboards

Create custom dashboards to monitor:
- Website traffic (CloudFront metrics)
- Build success/failure rates
- S3 storage usage
- Error rates

### Alerts Setup

```bash
# Create CloudWatch alarm for build failures
aws cloudwatch put-metric-alarm \
  --alarm-name "CodeBuild-Failures" \
  --alarm-description "Alert on build failures" \
  --metric-name "FailedBuilds" \
  --namespace "AWS/CodeBuild" \
  --statistic "Sum" \
  --period 300 \
  --threshold 1 \
  --comparison-operator "GreaterThanOrEqualToThreshold"
```

### Regular Maintenance

1. **Update dependencies** in package.json regularly
2. **Review CloudWatch logs** for errors
3. **Monitor costs** via AWS Cost Explorer
4. **Update SSL certificates** (auto-renewed with ACM)
5. **Review IAM policies** for security

---

## 🔒 Security Best Practices

### Implemented Security Features

- ✅ S3 bucket is private (no public access)
- ✅ CloudFront enforces HTTPS
- ✅ IAM roles use least privilege principle
- ✅ SSL certificate auto-renewal
- ✅ Security headers via CloudFront

### Additional Security Measures

1. **Enable AWS Config** for compliance monitoring
2. **Use AWS WAF** for web application firewall
3. **Enable CloudTrail** for audit logging
4. **Implement resource tagging** for governance

---

## 🚀 Next Steps

After successful deployment:

1. **Setup Analytics**
   - Add Google Analytics to your React app
   - Monitor CloudWatch metrics

2. **Performance Optimization**
   - Implement code splitting
   - Optimize images
   - Add PWA features

3. **Content Management**
   - Add a CMS for blog posts
   - Implement contact form backend

4. **Advanced Features**
   - Add search functionality
   - Implement user authentication
   - Add real-time features

---

## 🆘 Support

If you encounter issues:

1. **Check AWS Documentation**
   - [S3 Static Website Hosting](https://docs.aws.amazon.com/AmazonS3/latest/dev/WebsiteHosting.html)
   - [CloudFront Documentation](https://docs.aws.amazon.com/cloudfront/)
   - [CodePipeline User Guide](https://docs.aws.amazon.com/codepipeline/)

2. **AWS Support**
   - Basic support is free
   - Developer support: $29/month
   - Business support: $100/month

3. **Community Resources**
   - AWS Forums
   - Stack Overflow
   - Reddit r/aws

---

**🎉 Congratulations! Your portfolio website is now live on AWS with professional CI/CD automation!**