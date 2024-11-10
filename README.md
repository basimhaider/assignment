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
   ```bash
   cd terraform
   terraform init
   terraform apply
   ```

2. Push Docker image and deploy:
   ```bash
   docker build -t <image> .
   helm install my-java-app ./helm
   ```

## CI/CD Pipeline
The GitHub Actions workflow automates:
- Building the Docker image.
- Pushing the image to AWS ECR.
- Deploying the application to EKS using Helm.

