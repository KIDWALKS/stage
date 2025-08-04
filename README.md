# Kidwalks Inventory - Stage Environment 🏗️

Stage environment for the Kidwalks inventory management application with comprehensive CI/CD pipeline.

## 🚀 Overview

This repository contains the staging environment configuration and automated deployment pipeline for the Kidwalks inventory management system. The application consists of a Next.js frontend client and Node.js backend server, deployed using containerized infrastructure.

## 🏗️ Architecture

- **Frontend**: Next.js application (React-based)
- **Backend**: Node.js/Express API server
- **Database**: PostgreSQL (AWS RDS)
- **Container Registry**: Amazon ECR
- **Deployment**: Docker Compose on AWS EC2
- **CI/CD**: GitHub Actions with comprehensive security scanning

## 📦 Deployment Strategy

### Tag-Based Deployment
Deployments are triggered by pushing version tags:

```bash
# Create and push a version tag
git tag v1.0.4
git push origin v1.0.4
```

This triggers the automated pipeline that:
1. Builds Docker images
2. Runs security scans (SonarQube, Checkov, Trivy)
3. Pushes images to ECR with version tags
4. Deploys to EC2 using docker-compose

### Docker Images
- **Client**: `inventoryapp-client-stage:${VERSION_TAG}`
- **Server**: `inventoryapp-server-stage:${VERSION_TAG}`

## 🔧 CI/CD Pipeline

The GitHub Actions workflow includes:

### 🧪 Code Quality & Security
- **SonarQube**: Code quality analysis
- **Checkov**: Infrastructure security scanning
- **Trivy**: Container vulnerability scanning

### 🐳 Containerization
- Multi-stage Docker builds for optimal image size
- Versioned image tagging
- ECR registry push with both version and `latest` tags

### 🚀 Deployment
- SSH-based deployment to EC2
- Docker Compose orchestration
- Automatic container health checks
- Zero-downtime deployment strategy

## 🌐 Environment Configuration

### Required GitHub Secrets
| Secret | Description | Example |
|--------|-------------|---------|
| `AWS_REGION` | AWS deployment region | `us-east-1` |
| `ECR_ACCOUNT_ID` | AWS Account ID | `123456789012` |
| `AWS_ACCESS_KEY_ID` | AWS credentials | `AKIA...` |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key | `your-secret-key` |
| `EC2_HOST` | EC2 instance hostname | `ec2-xx-xx-xx-xx.compute-1.amazonaws.com` |
| `EC2_USER` | EC2 SSH username | `ubuntu` |
| `EC2_KEY` | EC2 private key | `-----BEGIN RSA PRIVATE KEY-----...` |
| `STAGE_DOMAIN` | Stage domain URL | `stage.kidwalks.com` |
| `SONAR_TOKEN` | SonarQube token | `sq_...` |
| `SONAR_HOST_URL` | SonarQube server URL | `https://sonar.domain.com` |

### Application Configuration
- **Frontend Port**: 3000
- **Backend Port**: 3001
- **Database**: PostgreSQL on AWS RDS
- **API Base URL**: Configured via environment variables

## 🐳 Docker Compose

The application uses versioned images from ECR:

```yaml
services:
  server:
    image: ${ECR_REGISTRY}/inventoryapp-server-stage:${VERSION_TAG:-latest}
    ports:
      - "3001:3001"
    environment:
      DATABASE_URL: postgresql://...

  client:
    image: ${ECR_REGISTRY}/inventoryapp-client-stage:${VERSION_TAG:-latest}
    ports:
      - "3000:3000"
    depends_on:
      - server
```

## 🔄 Deployment Process

1. **Push Version Tag**: `git tag v1.x.x && git push origin v1.x.x`
2. **Automated Pipeline**: GitHub Actions executes the full CI/CD pipeline
3. **Security Scans**: Code quality and vulnerability assessments
4. **Image Build**: Docker images built and tagged with version
5. **ECR Push**: Images pushed to Amazon ECR
6. **EC2 Deployment**: SSH deployment using docker-compose
7. **Health Check**: Container logs and status verification

## 📊 Monitoring & Logs

Post-deployment verification includes:
- Container status checks
- Application logs inspection
- Service health validation
- Deployment confirmation

## 🔗 Access

- **Stage Application**: https://[STAGE_DOMAIN]
- **Health Check**: Available via pipeline logs
- **Container Logs**: Monitored during deployment

## 🛠️ Development Workflow

1. Develop features in feature branches
2. Create pull requests to main
3. After merge, create version tag for deployment
4. Monitor deployment via GitHub Actions
5. Verify deployment on stage environment

## 📝 Version History

All deployments are tracked via Git tags and ECR image versions, providing complete traceability and rollback capabilities.
