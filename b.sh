#!/bin/bash

# Function to set up the directory structure
setup_directory_structure() {
  echo "Setting up project directory structure..."
  mkdir -p terraform helm/templates .github/workflows
}

# Function to create Dockerfile
create_dockerfile() {
  echo "Creating Dockerfile..."
  cat > Dockerfile <<EOL
# Use an official Java runtime as a parent image
FROM openjdk:11-jre-slim

# Set the working directory
WORKDIR /app

# Copy the application JAR file
COPY target/*.jar app.jar

# Expose port 8080
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
EOL
}

# Function to create Helm chart files
create_helm_chart() {
  echo "Creating Helm chart files..."
  
  # Chart.yaml
  cat > helm/Chart.yaml <<EOL
apiVersion: v2
name: my-java-app
description: A Helm chart for deploying Java application
version: 0.1.0
appVersion: "1.0.0"
EOL

  # values.yaml
  cat > helm/values.yaml <<EOL
replicaCount: 2
image:
  repository: my-java-app
  pullPolicy: IfNotPresent
service:
  type: ClusterIP
  port: 8080
ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: nginx
  hosts:
    - host: myapp.local
      paths:
        - path: /
          pathType: Prefix
EOL

  # Deployment template
  cat > helm/templates/deployment.yaml <<EOL
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-java-app
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: my-java-app
  template:
    metadata:
      labels:
        app: my-java-app
    spec:
      containers:
        - name: my-java-app
          image: "{{ .Values.image.repository }}"
          ports:
            - containerPort: 8080
EOL

  # Service template
  cat > helm/templates/service.yaml <<EOL
apiVersion: v1
kind: Service
metadata:
  name: my-java-app
spec:
  selector:
    app: my-java-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
EOL

  # Ingress template
  cat > helm/templates/ingress.yaml <<EOL
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-java-app
  annotations:
    kubernetes.io/ingress.class: nginx
spec:
  rules:
    - host: myapp.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: my-java-app
                port:
                  number: 80
EOL
}

# Function to create Terraform files
create_terraform_files() {
  echo "Creating Terraform files..."
  
  # Provider configuration
  cat > terraform/provider.tf <<EOL
provider "aws" {
  region = var.region
}
EOL

  # Variables
  cat > terraform/variables.tf <<EOL
variable "region" {
  description = "AWS region"
  default     = "us-west-2"
}

variable "cluster_name" {
  description = "EKS cluster name"
  default     = "my-java-app-cluster"
}
EOL

  # EKS setup
  cat > terraform/eks.tf <<EOL
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster_name
  cluster_version = "1.25"
  node_groups = {
    eks_nodes = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1
      instance_type    = "t3.medium"
    }
  }
}
EOL
}

# Function to create GitHub Actions workflow
create_github_workflow() {
  echo "Creating GitHub Actions workflow..."
  
  cat > .github/workflows/deploy.yml <<EOL
name: Deploy Java App to EKS

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          role-to-assume: \$\{{ secrets.AWS_ROLE_TO_ASSUME }}
          aws-region: \$\{{ secrets.AWS_REGION }}

      - name: Build Docker image
        run: |
          docker build -t \${{ secrets.ECR_REPO_URL }}:latest .
          aws ecr get-login-password --region \$\{{ secrets.AWS_REGION }} | docker login --username AWS --password-stdin \$\{{ secrets.ECR_REPO_URL }}
          docker push \${{ secrets.ECR_REPO_URL }}:latest

      - name: Deploy to Kubernetes using Helm
        run: |
          helm upgrade --install my-java-app ./helm --namespace default --set image.repository=\${{ secrets.ECR_REPO_URL }}:latest
EOL
}

# Function to create README.md
create_readme() {
  echo "Creating README.md..."
  cat > README.md <<EOL
# Deploying a Java Application to AWS EKS

This repository demonstrates deploying a Java application to AWS Elastic Kubernetes Service (EKS) using:
- Terraform for Infrastructure as Code (IaC)
- Helm for Kubernetes Deployment
- GitHub Actions for CI/CD

## Features
- Dockerized Java application.
- Production-ready Kubernetes Helm chart.
- Secure role-based AWS authentication for deployment.

## Prerequisites
1. AWS CLI, Terraform, Helm, and kubectl installed locally.
2. AWS IAM Role configured for GitHub Actions.

## Setup
1. Initialize Terraform:
   \`\`\`bash
   cd terraform
   terraform init
   terraform apply
   \`\`\`

2. Push Docker image and deploy:
   \`\`\`bash
   docker build -t <image> .
   helm install my-java-app ./helm
   \`\`\`

## CI/CD Pipeline
The GitHub Actions workflow automates:
- Building the Docker image.
- Pushing the image to AWS ECR.
- Deploying the application to EKS using Helm.

EOL
}

# Function to push to GitHub
push_to_github() {
  echo "Pushing to GitHub..."
  git add .
  git commit -m "Complete setup: Dockerfile, Helm, Terraform, CI/CD pipeline"
  git branch -M main
  git remote add origin git@github.com:basimhaider/assignment.git
  git push -u origin main
}

# Run all setup steps
setup_directory_structure
create_dockerfile
create_helm_chart
create_terraform_files
create_github_workflow
create_readme
push_to_github

echo "Setup complete! All files created and pushed to GitHub."
