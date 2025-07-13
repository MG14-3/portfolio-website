# GitHub Repository Setup Guide

This guide helps you prepare your GitHub repository for AWS deployment with CodePipeline.

## 🔧 Repository Structure

Your repository should have this structure:

```
your-portfolio-website/
├── frontend/                    # React application
│   ├── src/
│   │   ├── App.js
│   │   ├── App.css
│   │   ├── index.js
│   │   └── ...
│   ├── public/
│   │   ├── index.html
│   │   └── ...
│   ├── package.json
│   ├── package-lock.json
│   └── ...
├── buildspec.yml               # CodeBuild configuration (ROOT level)
├── aws-infrastructure/         # Deployment files
│   ├── terraform/
│   ├── cloudformation/
│   └── ...
├── README.md
└── .gitignore
```

## 📋 Step-by-Step Setup

### 1. Create GitHub Repository

1. **Go to GitHub and create a new repository**
   - Repository name: `portfolio-website` (or your preferred name)
   - Description: "My personal portfolio website"
   - Public or Private: Your choice
   - Initialize with README: ✅

2. **Clone to your local machine**
   ```bash
   git clone https://github.com/yourusername/portfolio-website.git
   cd portfolio-website
   ```

### 2. Copy Portfolio Code

1. **Copy your React application**
   ```bash
   # Copy the frontend folder from your current project
   cp -r /path/to/your/frontend ./frontend
   ```

2. **Copy AWS infrastructure files**
   ```bash
   # Copy the entire aws-infrastructure folder
   cp -r /path/to/your/aws-infrastructure ./aws-infrastructure
   ```

3. **Copy buildspec.yml to root**
   ```bash
   # IMPORTANT: buildspec.yml must be in repository root
   cp aws-infrastructure/buildspec.yml ./buildspec.yml
   ```

### 3. Update package.json

Ensure your `frontend/package.json` has the correct build script:

```json
{
  "name": "portfolio-frontend",
  "version": "0.1.0",
  "private": true,
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-scripts": "5.0.1"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject"
  },
  "eslintConfig": {
    "extends": [
      "react-app",
      "react-app/jest"
    ]
  },
  "browserslist": {
    "production": [
      ">0.2%",
      "not dead",
      "not op_mini all"
    ],
    "development": [
      "last 1 chrome version",
      "last 1 firefox version",
      "last 1 safari version"
    ]
  }
}
```

### 4. Create .gitignore

Create a `.gitignore` file in the root:

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
```

### 5. Create GitHub Personal Access Token

1. **Go to GitHub Settings**
   - Click your profile → Settings
   - Navigate to Developer settings → Personal access tokens → Tokens (classic)

2. **Generate New Token**
   - Click "Generate new token (classic)"
   - Note: Give it a descriptive name like "Portfolio AWS Deploy"
   - Expiration: 90 days (recommended)

3. **Select Permissions**
   - ✅ `repo` (Full control of private repositories)
   - ✅ `admin:repo_hook` (Write repository hooks)

4. **Generate and Save Token**
   - Click "Generate token"
   - **IMPORTANT**: Copy the token immediately (you won't see it again)
   - Store it securely - you'll need it for AWS deployment

### 6. Commit and Push

```bash
# Add all files
git add .

# Commit changes
git commit -m "Initial commit: Add portfolio website and AWS infrastructure"

# Push to GitHub
git push origin main
```

### 7. Verify Repository Structure

Check that your repository has:

- ✅ `buildspec.yml` in root directory
- ✅ `frontend/` directory with React app
- ✅ `frontend/package.json` with build script
- ✅ `aws-infrastructure/` directory with deployment files
- ✅ Proper `.gitignore`

## 🔐 Security Considerations

### Token Security

1. **Never commit tokens to repository**
   - Add `.env` files to `.gitignore`
   - Use environment variables for sensitive data

2. **Token Permissions**
   - Use minimum required permissions
   - Set reasonable expiration dates
   - Rotate tokens regularly

3. **Repository Secrets**
   - Consider using GitHub Secrets for sensitive data
   - Never hardcode API keys or credentials

### Branch Protection

1. **Protect main branch**
   - Go to Settings → Branches
   - Add branch protection rule for `main`
   - Require pull request reviews
   - Require status checks

2. **Setup Branch Strategy**
   ```
   main (production)
   ├── develop (development)
   └── feature/* (feature branches)
   ```

## 📝 buildspec.yml Configuration

Your `buildspec.yml` should be in the repository root:

```yaml
version: 0.2

phases:
  install:
    runtime-versions:
      nodejs: 18
    commands:
      - echo Installing dependencies...
      - cd frontend
      - npm install
      
  pre_build:
    commands:
      - echo Running pre-build steps...
      - npm run test -- --coverage --ci
      
  build:
    commands:
      - echo Building the React application...
      - npm run build
      
  post_build:
    commands:
      - echo Deploying to S3...
      - aws s3 sync build/ s3://$S3_BUCKET --delete
      - echo Invalidating CloudFront cache...
      - aws cloudfront create-invalidation --distribution-id $CLOUDFRONT_DISTRIBUTION_ID --paths "/*"

artifacts:
  files:
    - '**/*'
  base-directory: frontend/build
  name: portfolio-build

cache:
  paths:
    - frontend/node_modules/**/*
```

## 🔄 CI/CD Workflow

### Automated Deployment Process

1. **Developer pushes code** to `main` branch
2. **GitHub webhook** triggers CodePipeline
3. **CodePipeline** pulls source code
4. **CodeBuild** runs build process:
   - Install dependencies
   - Run tests
   - Build React app
   - Deploy to S3
   - Invalidate CloudFront cache
5. **Website is live** with new changes

### Manual Deployment Trigger

```bash
# Force pipeline execution
aws codepipeline start-pipeline-execution --name your-pipeline-name
```

## 🧪 Testing Your Setup

### Local Testing

1. **Test React build locally**
   ```bash
   cd frontend
   npm install
   npm run build
   npm run test
   ```

2. **Verify buildspec.yml syntax**
   ```bash
   # Use AWS CLI to validate
   aws codebuild batch-get-projects --names your-project-name
   ```

### Repository Validation

1. **Check file permissions**
   ```bash
   ls -la buildspec.yml  # Should be readable
   ```

2. **Validate JSON files**
   ```bash
   # Check package.json syntax
   cd frontend && npm install --dry-run
   ```

3. **Test Git workflow**
   ```bash
   # Make a small change and test
   echo "# Test" >> README.md
   git add README.md
   git commit -m "Test commit"
   git push origin main
   ```

## 📊 Repository Best Practices

### Commit Messages

Use conventional commit format:
```
feat: add new portfolio section
fix: resolve mobile responsiveness issue
docs: update deployment guide
style: improve CSS styling
refactor: optimize component structure
test: add unit tests for components
```

### Branch Naming

```
feature/add-blog-section
bugfix/fix-mobile-navigation
hotfix/critical-security-patch
release/v1.0.0
```

### Code Organization

```
frontend/
├── src/
│   ├── components/          # Reusable components
│   ├── pages/              # Page components
│   ├── styles/             # CSS files
│   ├── utils/              # Utility functions
│   ├── hooks/              # Custom React hooks
│   └── assets/             # Images, fonts, etc.
├── public/
└── tests/                  # Test files
```

## 🔍 Monitoring Repository

### GitHub Actions (Optional)

Add `.github/workflows/ci.yml` for additional CI:

```yaml
name: CI
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      - name: Install dependencies
        run: cd frontend && npm install
      - name: Run tests
        run: cd frontend && npm test -- --coverage
      - name: Build project
        run: cd frontend && npm run build
```

### Repository Analytics

Monitor your repository:
- **Insights tab**: View contribution activity
- **Actions tab**: Monitor CI/CD runs
- **Security tab**: Check for vulnerabilities
- **Settings**: Configure repository rules

## 🚀 Ready for Deployment

Once your repository is set up:

1. ✅ Repository structure is correct
2. ✅ buildspec.yml is in root
3. ✅ GitHub token is created
4. ✅ Code is pushed to main branch
5. ✅ Local build works successfully

You're now ready to deploy to AWS! Continue with the main deployment guide.

---

**Next Step**: Run the AWS deployment script:
```bash
cd aws-infrastructure
./deploy.sh
```