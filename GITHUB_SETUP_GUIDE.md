# 🚀 GitHub Repository Setup & Push Guide

This guide provides step-by-step instructions to push your complete portfolio website and AWS infrastructure code to GitHub.

## 📋 Prerequisites

- GitHub account
- Git installed on your system
- SSH keys configured with GitHub (recommended) or HTTPS authentication

## 🔧 Step 1: Create GitHub Repository

### Option A: Using GitHub Web Interface
1. Go to [GitHub.com](https://github.com)
2. Click "New" or "+" → "New repository"
3. Repository name: `portfolio-website` (or your preferred name)
4. Description: `Professional portfolio website with AWS infrastructure`
5. Set to Public or Private (your choice)
6. **Do NOT initialize with README** (we already have one)
7. Click "Create repository"

### Option B: Using GitHub CLI (if installed)
```bash
gh repo create portfolio-website --public --description "Professional portfolio website with AWS infrastructure"
```

## 📁 Step 2: Prepare Local Repository

### Navigate to your project directory
```bash
cd /path/to/your/project
```

### Initialize Git repository (if not already done)
```bash
git init
```

### Create .gitignore file
Create a `.gitignore` file in the root directory:

```gitignore
# Dependencies
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Production build
frontend/build/

# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Logs
logs/
*.log

# AWS
.aws/

# Terraform
*.tfstate
*.tfstate.*
.terraform/
.terraform.lock.hcl

# CloudFormation
*.zip

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# Testing
coverage/
.coverage
.pytest_cache/
```

## 📦 Step 3: Add Files to Git

### Add all files
```bash
git add .
```

### Check what files are staged
```bash
git status
```

### Commit your changes
```bash
git commit -m "Initial commit: Complete portfolio website with AWS infrastructure

- React frontend with responsive design
- FastAPI backend with MongoDB
- Complete AWS infrastructure (Terraform & CloudFormation)
- CI/CD pipeline with CodePipeline & CodeBuild
- Comprehensive documentation and deployment guides"
```

## 🔗 Step 4: Connect to GitHub Repository

### Add remote origin (replace with your GitHub username/repo)
```bash
git remote add origin https://github.com/yourusername/portfolio-website.git
```

### Or if using SSH:
```bash
git remote add origin git@github.com:yourusername/portfolio-website.git
```

### Verify remote is added
```bash
git remote -v
```

## 🚀 Step 5: Push to GitHub

### Push to main branch
```bash
git branch -M main
git push -u origin main
```

### If you get authentication errors:
#### For HTTPS:
```bash
# Generate personal access token from GitHub settings
# Use token as password when prompted
git push -u origin main
```

#### For SSH:
```bash
# Make sure SSH keys are properly configured
ssh -T git@github.com
git push -u origin main
```

## 📂 Step 6: Verify Repository Structure

Your GitHub repository should now contain:

```
portfolio-website/
├── frontend/                    # React application
│   ├── src/
│   │   ├── App.js
│   │   ├── App.css
│   │   └── index.js
│   ├── public/
│   ├── package.json
│   └── ...
├── backend/                     # FastAPI backend
│   ├── server.py
│   ├── requirements.txt
│   └── .env
├── aws-infrastructure/          # AWS deployment code
│   ├── terraform/
│   │   ├── main.tf
│   │   └── terraform.tfvars.example
│   ├── cloudformation/
│   │   └── portfolio-infrastructure.yaml
│   ├── deploy.sh
│   ├── README.md
│   ├── DEPLOYMENT_GUIDE.md
│   └── github-setup.md
├── buildspec.yml               # CodeBuild configuration
├── DEPLOYMENT_SUMMARY.md       # Complete overview
├── README.md                   # Project documentation
└── .gitignore                  # Git ignore file
```

## 🔄 Step 7: Set Up Branch Protection (Optional)

For production repositories, consider setting up branch protection:

1. Go to your repository on GitHub
2. Navigate to Settings → Branches
3. Add branch protection rule for `main`
4. Enable:
   - Require pull request reviews
   - Require status checks
   - Restrict pushes to main branch

## 🎯 Step 8: Generate GitHub Personal Access Token

For AWS deployment, you'll need a GitHub personal access token:

1. Go to GitHub Settings → Developer settings → Personal access tokens
2. Generate new token (classic)
3. Give it a descriptive name: "Portfolio AWS Deploy"
4. Select scopes:
   - ✅ `repo` (Full control of private repositories)
   - ✅ `admin:repo_hook` (Write repository hooks)
5. Copy the token and save it securely

## 🚀 Step 9: Ready for AWS Deployment

Now that your code is on GitHub, you can deploy to AWS:

```bash
cd aws-infrastructure
./deploy.sh
```

Choose Option 2 (CloudFormation) and provide:
- Project name
- GitHub repository (format: `username/repository-name`)
- GitHub personal access token
- Domain name (optional)

## 📝 Step 10: Update README with Your Information

Edit the main `README.md` file to include:
- Your name and contact information
- Live website URL (after deployment)
- Any specific setup instructions
- Technologies used
- Screenshots of your portfolio

## 🔧 Common Git Commands for Future Updates

### Pull latest changes (if working from multiple machines)
```bash
git pull origin main
```

### Add and commit changes
```bash
git add .
git commit -m "Update: Brief description of changes"
```

### Push changes
```bash
git push origin main
```

### Create a new branch for features
```bash
git checkout -b feature/new-feature
# Make changes
git add .
git commit -m "Add new feature"
git push origin feature/new-feature
```

### Switch between branches
```bash
git checkout main
git checkout feature/new-feature
```

## 🐛 Troubleshooting

### Authentication Issues
```bash
# For HTTPS - use personal access token as password
git remote set-url origin https://github.com/yourusername/portfolio-website.git

# For SSH - ensure SSH keys are set up
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

### Large file issues
```bash
# If you accidentally commit large files
git reset --soft HEAD~1
git reset HEAD path/to/large/file
echo "path/to/large/file" >> .gitignore
git add .gitignore
git commit -m "Add large file to gitignore"
```

### Reset to last commit
```bash
git reset --hard HEAD
```

## 🎉 Success!

Your portfolio website code is now on GitHub and ready for:
- AWS deployment using the provided infrastructure code
- Collaboration with other developers
- Version control and change tracking
- Automated CI/CD pipeline

## 📞 Support

If you encounter any issues:
1. Check the error messages carefully
2. Verify your GitHub credentials
3. Ensure you have the correct repository permissions
4. Check the GitHub repository settings

---

**🎯 Next Steps:**
1. Follow the AWS deployment guide in `aws-infrastructure/DEPLOYMENT_GUIDE.md`
2. Set up the CI/CD pipeline using the provided infrastructure code
3. Customize the portfolio content with your actual information

**Your professional portfolio is now ready for the world! 🚀**