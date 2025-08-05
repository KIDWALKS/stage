# Kidwalks Inventory - Stage Environment 🏗️

Stage environment for the Kidwalks inventory management application with comprehensive CI/CD pipeline.

## 🚀 Overview

This repository contains the staging environment configuration and automated deployment pipeline for the Kidwalks inventory management system. The application consists of a Next.js frontend client and Node.js backend server, deployed using containerized infrastructure.

## ⚡ Quick Start

### Prerequisites
- AWS Account with ECR and EC2 access
- GitHub repository with required secrets configured
- Docker and Docker Compose installed on target EC2 instance

### Deploy Latest Version
```bash
# 1. Create and push a version tag
git tag v1.0.0
git push origin v1.0.0

# 2. Monitor deployment in GitHub Actions
# Visit: https://github.com/KIDWALKS/stage/actions

# 3. Access your application
# Frontend: https://your-domain:3100
# Backend: https://your-domain:3101
```

### Manual Quick Deploy
```bash
# On your EC2 instance
mkdir -p ~/kidwalksapparells-inventory-stage && cd ~/kidwalksapparells-inventory-stage
curl -o docker-compose.yml https://raw.githubusercontent.com/KIDWALKS/stage/main/docker-compose.yml
curl -o .env https://raw.githubusercontent.com/KIDWALKS/stage/main/.env.example
# Edit .env with your values
docker compose up -d
```

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

## 🐳 Docker Compose Configuration

The application uses versioned images from ECR with environment variables:

```yaml
version: '3.8'

services:
  server:
    image: "${ECR_REGISTRY}/inventoryapp-server-stage:${VERSION_TAG:-latest}"
    ports:
      - "3101:3001"
    environment:
      DATABASE_URL: "${DATABASE_URL}"
      AWS_ACCESS_KEY_ID: "${AWS_ACCESS_KEY_ID}"
      AWS_SECRET_ACCESS_KEY: "${AWS_SECRET_ACCESS_KEY}"
      AWS_REGION: "${AWS_REGION}"
      AWS_S3_BUCKET_NAME: "${AWS_S3_BUCKET_NAME}"

  client:
    image: "${ECR_REGISTRY}/inventoryapp-client-stage:${VERSION_TAG:-latest}"
    ports:
      - "3100:3000"
    depends_on:
      - server
    environment:
      NEXT_PUBLIC_API_BASE_URL: "${NEXT_PUBLIC_API_BASE_URL}"
```

### Environment Variables (.env file)
```bash
ECR_REGISTRY=123456789012.dkr.ecr.us-east-1.amazonaws.com
VERSION_TAG=v1.0.0
DATABASE_URL=postgresql://user:password@host:5432/database
NEXT_PUBLIC_API_BASE_URL=https://stage.kidwalks.com
AWS_ACCESS_KEY_ID=AKIA...
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_REGION=us-east-1
AWS_S3_BUCKET_NAME=your-bucket-name
```

### Port Configuration
- **Client (Frontend)**: Port 3100 → 3000 (container)
- **Server (Backend)**: Port 3101 → 3001 (container)
- **Access URLs**:
  - Frontend: `http://your-domain:3100`
  - Backend API: `http://your-domain:3101`

## 🔄 Deployment Process

### Automated Deployment (Recommended)

1. **Push Version Tag**: 
   ```bash
   git tag v1.x.x && git push origin v1.x.x
   ```

2. **Automated Pipeline**: GitHub Actions executes the full CI/CD pipeline
3. **Security Scans**: Code quality and vulnerability assessments  
4. **Image Build**: Docker images built and tagged with version
5. **ECR Push**: Images pushed to Amazon ECR
6. **EC2 Deployment**: SSH deployment using docker-compose
7. **Health Check**: Container logs and status verification

### Manual Deployment Steps

If you need to deploy manually or troubleshoot:

```bash
# 1. Clone the repository
git clone https://github.com/KIDWALKS/stage.git
cd stage

# 2. Configure AWS credentials (if not using GitHub Actions)
aws configure set aws_access_key_id YOUR_ACCESS_KEY
aws configure set aws_secret_access_key YOUR_SECRET_KEY
aws configure set region us-east-1

# 3. Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin YOUR_ACCOUNT.dkr.ecr.us-east-1.amazonaws.com

# 4. Build and tag images
docker build -t YOUR_ACCOUNT.dkr.ecr.us-east-1.amazonaws.com/inventoryapp-client-stage:v1.0.0 -f client/Dockerfile .
docker build -t YOUR_ACCOUNT.dkr.ecr.us-east-1.amazonaws.com/inventoryapp-server-stage:v1.0.0 -f server/Dockerfile .

# 5. Push images to ECR
docker push YOUR_ACCOUNT.dkr.ecr.us-east-1.amazonaws.com/inventoryapp-client-stage:v1.0.0
docker push YOUR_ACCOUNT.dkr.ecr.us-east-1.amazonaws.com/inventoryapp-server-stage:v1.0.0

# 6. Deploy on EC2 (SSH into your instance)
ssh -i your-key.pem ubuntu@your-ec2-host

# 7. On EC2: Setup deployment directory
mkdir -p ~/kidwalksapparells-inventory-stage
cd ~/kidwalksapparells-inventory-stage

# 8. Download docker-compose.yml
curl -o docker-compose.yml https://raw.githubusercontent.com/KIDWALKS/stage/main/docker-compose.yml

# 9. Create .env file with your configuration
cat <<EOF > .env
ECR_REGISTRY=YOUR_ACCOUNT.dkr.ecr.us-east-1.amazonaws.com
VERSION_TAG=v1.0.0
DATABASE_URL=postgresql://user:password@host:5432/database
NEXT_PUBLIC_API_BASE_URL=https://your-stage-domain.com
AWS_ACCESS_KEY_ID=YOUR_ACCESS_KEY
AWS_SECRET_ACCESS_KEY=YOUR_SECRET_KEY
AWS_REGION=us-east-1
AWS_S3_BUCKET_NAME=your-bucket-name
EOF

# 10. Deploy with docker-compose
docker compose down
docker compose up -d

# 11. Verify deployment
docker ps
docker logs container_name
```

## 🔧 Version Management

### Available Commands

```bash
# List all available versions
git tag -l

# Check current deployed version
docker ps --format "table {{.Image}}\t{{.Names}}\t{{.Status}}"

# List ECR repository tags
aws ecr describe-images --repository-name inventoryapp-client-stage --query 'imageDetails[*].imageTags' --output table

# Rollback to previous version
git tag v1.0.5 <previous-commit-hash>
git push origin v1.0.5
```

### Version Deployment Examples

```bash
# Deploy version 1.0.0
git tag v1.0.0
git push origin v1.0.0

# Deploy hotfix version
git tag v1.0.1
git push origin v1.0.1

# Deploy major version
git tag v2.0.0
git push origin v2.0.0
```

## 🛠️ Development Workflow

### 1. Feature Development
```bash
# Create feature branch
git checkout -b feature/new-feature
# Make changes
git add .
git commit -m "Add new feature"
git push origin feature/new-feature
```

### 2. Create Pull Request
- Open PR from feature branch to main
- Code review and approval
- Merge to main branch

### 3. Deploy to Stage
```bash
# After merge, create version tag
git checkout main
git pull origin main
git tag v1.x.x
git push origin v1.x.x
```

### 4. Monitor Deployment
- Check GitHub Actions workflow progress
- Verify deployment in stage environment
- Review container logs and health status

## 📊 Monitoring & Troubleshooting

### Container Health Checks

```bash
# Check running containers
docker ps

# View container logs
docker logs container_name

# Follow live logs
docker logs -f container_name

# Check container resource usage
docker stats

# Inspect container details
docker inspect container_name
```

### Application Logs

```bash
# Client application logs
docker logs kidwalksapparells-inventory-stage-client-1

# Server application logs  
docker logs kidwalksapparells-inventory-stage-server-1

# Tail last 50 lines
docker logs --tail=50 container_name

# Follow logs with timestamps
docker logs -f -t container_name
```

### Deployment Verification

```bash
# Test application endpoints
curl -I https://your-stage-domain.com
curl -I https://your-stage-domain.com/api/health

# Check port connectivity
telnet your-ec2-host 3100  # Client port
telnet your-ec2-host 3101  # Server port

# Verify environment variables
docker exec container_name env | grep VERSION_TAG
```

### Common Troubleshooting

#### 1. Image Pull Issues
```bash
# Re-authenticate with ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin YOUR_ACCOUNT.dkr.ecr.us-east-1.amazonaws.com

# Manually pull images
docker pull YOUR_ACCOUNT.dkr.ecr.us-east-1.amazonaws.com/inventoryapp-client-stage:latest
```

#### 2. Container Startup Issues
```bash
# Check if ports are already in use
netstat -tlnp | grep :3100
netstat -tlnp | grep :3101

# Remove conflicting containers
docker rm -f $(docker ps -aq --filter "name=inventory")

# Restart with fresh containers
docker compose down
docker compose up -d
```

#### 3. Environment Configuration Issues
```bash
# Verify .env file
cat .env

# Check environment variables in container
docker exec container_name printenv

# Recreate .env file
rm .env
# Recreate with correct values
```

#### 4. Database Connection Issues
```bash
# Test database connectivity from container
docker exec server_container pg_isready -h your-db-host -p 5432

# Check database logs
# (Access via AWS RDS console)
```

## 🔗 Useful Links & Access

### Application Access
- **Stage Application**: https://[STAGE_DOMAIN]
- **API Documentation**: https://[STAGE_DOMAIN]/api/docs
- **Health Check**: https://[STAGE_DOMAIN]/health

### Development Resources
- **GitHub Repository**: https://github.com/KIDWALKS/stage
- **GitHub Actions**: https://github.com/KIDWALKS/stage/actions
- **ECR Console**: https://console.aws.amazon.com/ecr/repositories
- **EC2 Console**: https://console.aws.amazon.com/ec2/home

### Monitoring Tools
- **CloudWatch Logs**: Monitor application logs
- **SonarCloud**: Code quality dashboard
- **Container Logs**: Real-time via SSH or GitHub Actions

## � Emergency Procedures

### Quick Rollback
```bash
# If current deployment fails, quick rollback:
ssh -i your-key.pem ubuntu@your-ec2-host
cd ~/kidwalksapparells-inventory-stage

# Use previous working version
sed -i 's/VERSION_TAG=v1.x.x/VERSION_TAG=v1.x.y/' .env
docker compose down
docker compose up -d
```

### Container Recovery
```bash
# If containers become unresponsive:
docker compose down
docker system prune -f
docker compose up -d
```

### Emergency Contact
- Check GitHub Actions logs for detailed error information
- Review container logs for application-specific issues
- Verify AWS service status if infrastructure issues occur

## 📝 Version History

All deployments are tracked via Git tags and ECR image versions, providing complete traceability and rollback capabilities.
