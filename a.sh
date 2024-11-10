#!/bin/bash

# Check if Git is initialized
if [ ! -d ".git" ]; then
  echo "Initializing Git repository..."
  git init
else
  echo "Git repository already initialized."
fi

# Create Dockerfile
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

# Create README.md
echo "Creating README.md..."
cat > README.md <<EOL
# Java Application Deployment to AWS EKS

This project demonstrates deploying a Java application to AWS Elastic Kubernetes Service (EKS) using GitHub Actions and Terraform.

## Features
- **Dockerized Java application** built using Spring Boot.
- **Helm chart** for Kubernetes deployment.
- **Terraform** for AWS infrastructure provisioning.
- **GitHub Actions** for CI/CD pipeline.

## Steps to Run

1. Build the Docker image:
   \`\`\`bash
   docker build -t my-java-app .
   \`\`\`

2. Push the Docker image to your registry.

3. Deploy to Kubernetes using Helm:
   \`\`\`bash
   helm install my-java-app ./helm
   \`\`\`

## Prerequisites
- AWS CLI, kubectl, and Helm installed locally.
- GitHub repository secrets configured for CI/CD.
EOL

# Create a .gitignore file
echo "Creating .gitignore..."
cat > .gitignore <<EOL
target/
*.jar
*.log
node_modules/
EOL

# Add Helm chart directory
echo "Creating Helm chart directory and templates..."
mkdir -p helm/templates

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

# Add all files to Git
echo "Adding files to Git..."
git add .

# Commit changes
echo "Committing files..."
git commit -m "Initial commit: Java app setup with Dockerfile, Helm chart, and README"

# Push to GitHub
echo "Pushing to GitHub..."
git branch -M main
git remote add origin git@github.com:basimhaider/assignment.git
git push -u origin main

echo "All files created and pushed to GitHub successfully."
