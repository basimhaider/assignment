# Java Application Deployment to AWS EKS

This project demonstrates deploying a Java application to AWS Elastic Kubernetes Service (EKS) using GitHub Actions and Terraform.

## Features
- **Dockerized Java application** built using Spring Boot.
- **Helm chart** for Kubernetes deployment.
- **Terraform** for AWS infrastructure provisioning.
- **GitHub Actions** for CI/CD pipeline.

## Steps to Run

1. Build the Docker image:
   ```bash
   docker build -t my-java-app .
   ```

2. Push the Docker image to your registry.

3. Deploy to Kubernetes using Helm:
   ```bash
   helm install my-java-app ./helm
   ```

## Prerequisites
- AWS CLI, kubectl, and Helm installed locally.
- GitHub repository secrets configured for CI/CD.
