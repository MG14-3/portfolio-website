#!/bin/bash

# AWS Portfolio Website Deployment Script
# This script helps deploy the infrastructure using either Terraform or CloudFormation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

# Function to check if AWS CLI is installed and configured
check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Please install it first."
        echo "Visit: https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html"
        exit 1
    fi

    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS CLI is not configured. Please run 'aws configure' first."
        exit 1
    fi

    print_status "AWS CLI is installed and configured."
}

# Function to check if Terraform is installed
check_terraform() {
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install it first."
        echo "Visit: https://learn.hashicorp.com/tutorials/terraform/install-cli"
        exit 1
    fi

    print_status "Terraform is installed."
}

# Function to deploy using Terraform
deploy_with_terraform() {
    print_header "DEPLOYING WITH TERRAFORM"
    
    cd terraform
    
    # Check if terraform.tfvars exists
    if [ ! -f "terraform.tfvars" ]; then
        print_warning "terraform.tfvars not found. Creating from example..."
        cp terraform.tfvars.example terraform.tfvars
        print_error "Please edit terraform.tfvars with your values and run this script again."
        exit 1
    fi
    
    print_status "Initializing Terraform..."
    terraform init
    
    print_status "Planning Terraform deployment..."
    terraform plan
    
    read -p "Do you want to apply these changes? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Applying Terraform configuration..."
        terraform apply -auto-approve
        
        print_status "Deployment completed successfully!"
        print_status "Outputs:"
        terraform output
    else
        print_warning "Deployment cancelled."
    fi
    
    cd ..
}

# Function to deploy using CloudFormation
deploy_with_cloudformation() {
    print_header "DEPLOYING WITH CLOUDFORMATION"
    
    # Parameters
    read -p "Enter project name (default: portfolio-website): " PROJECT_NAME
    PROJECT_NAME=${PROJECT_NAME:-portfolio-website}
    
    read -p "Enter domain name (optional, press enter to skip): " DOMAIN_NAME
    
    read -p "Enter GitHub repository (format: username/repo): " GITHUB_REPO
    if [ -z "$GITHUB_REPO" ]; then
        print_error "GitHub repository is required."
        exit 1
    fi
    
    read -p "Enter GitHub branch (default: main): " GITHUB_BRANCH
    GITHUB_BRANCH=${GITHUB_BRANCH:-main}
    
    read -s -p "Enter GitHub personal access token: " GITHUB_TOKEN
    echo
    if [ -z "$GITHUB_TOKEN" ]; then
        print_error "GitHub token is required."
        exit 1
    fi
    
    # Build parameters
    PARAMS="ParameterKey=ProjectName,ParameterValue=$PROJECT_NAME"
    PARAMS="$PARAMS ParameterKey=GitHubRepo,ParameterValue=$GITHUB_REPO"
    PARAMS="$PARAMS ParameterKey=GitHubBranch,ParameterValue=$GITHUB_BRANCH"
    PARAMS="$PARAMS ParameterKey=GitHubToken,ParameterValue=$GITHUB_TOKEN"
    
    if [ ! -z "$DOMAIN_NAME" ]; then
        PARAMS="$PARAMS ParameterKey=DomainName,ParameterValue=$DOMAIN_NAME"
    fi
    
    STACK_NAME="$PROJECT_NAME-stack"
    
    print_status "Deploying CloudFormation stack: $STACK_NAME"
    
    aws cloudformation deploy \
        --template-file cloudformation/portfolio-infrastructure.yaml \
        --stack-name $STACK_NAME \
        --parameter-overrides $PARAMS \
        --capabilities CAPABILITY_NAMED_IAM \
        --region us-east-1
    
    if [ $? -eq 0 ]; then
        print_status "CloudFormation deployment completed successfully!"
        
        print_status "Getting stack outputs..."
        aws cloudformation describe-stacks \
            --stack-name $STACK_NAME \
            --query 'Stacks[0].Outputs' \
            --output table
    else
        print_error "CloudFormation deployment failed."
        exit 1
    fi
}

# Function to setup GitHub webhook
setup_github_webhook() {
    print_header "GITHUB WEBHOOK SETUP"
    print_status "GitHub webhook will be automatically configured by CodePipeline."
    print_status "Make sure your GitHub repository has the following:"
    echo "  - buildspec.yml file in the root directory"
    echo "  - React frontend code in the 'frontend' directory"
    echo "  - GitHub personal access token with repo permissions"
}

# Function to validate GitHub repository structure
validate_repo_structure() {
    print_header "VALIDATING REPOSITORY STRUCTURE"
    
    # Check if we're in a Git repository
    if ! git status &> /dev/null; then
        print_warning "Not in a Git repository. Make sure to initialize Git and push to GitHub."
        return
    fi
    
    # Check for required files
    if [ ! -f "../buildspec.yml" ]; then
        print_error "buildspec.yml not found in repository root."
        print_status "Creating buildspec.yml..."
        cp ../buildspec.yml.example ../buildspec.yml
    fi
    
    if [ ! -d "../frontend" ]; then
        print_error "frontend directory not found."
        print_status "Make sure your React application is in the 'frontend' directory."
    fi
    
    print_status "Repository structure validation completed."
}

# Main menu
show_menu() {
    print_header "AWS PORTFOLIO WEBSITE DEPLOYMENT"
    echo "Choose your deployment method:"
    echo "1) Deploy with Terraform"
    echo "2) Deploy with CloudFormation"
    echo "3) Validate repository structure"
    echo "4) Setup GitHub webhook info"
    echo "5) Exit"
    echo
}

# Main execution
main() {
    check_aws_cli
    
    while true; do
        show_menu
        read -p "Enter your choice (1-5): " choice
        
        case $choice in
            1)
                check_terraform
                deploy_with_terraform
                ;;
            2)
                deploy_with_cloudformation
                ;;
            3)
                validate_repo_structure
                ;;
            4)
                setup_github_webhook
                ;;
            5)
                print_status "Goodbye!"
                exit 0
                ;;
            *)
                print_error "Invalid choice. Please try again."
                ;;
        esac
        
        echo
        read -p "Press Enter to continue..."
    done
}

# Run main function
main