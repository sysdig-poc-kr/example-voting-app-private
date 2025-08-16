# Example Voting App with Sysdig Security Integration

A simple distributed application running across multiple Docker containers with integrated **Sysdig v6 security scanning**.

## 🔒 Security Features

This repository includes a complete **DevSecOps pipeline** with:
- **Container Image Scanning**: Vulnerability assessment for all microservices
- **Infrastructure as Code (IaC) Scanning**: Kubernetes manifest security validation
- **GitHub Security Integration**: Automated SARIF report uploads
- **Continuous Security Monitoring**: Scan results in GitHub Security tab

### Security Scan Coverage
| Service | Technology | Risk Level | Scan Focus |
|---------|------------|------------|------------|
| Vote | Python Flask | Medium | Python packages, OS vulnerabilities |
| Worker | .NET Core | Low | .NET dependencies, runtime security |
| Result | Node.js | **High** | npm packages, JavaScript vulnerabilities |
| IaC | Kubernetes | Critical | Security contexts, network policies |

## 🚀 Getting Started

### Prerequisites
- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [Docker Compose](https://docs.docker.com/compose) (auto-installed with Docker Desktop)

### Quick Start
```shell
# Clone and run the application
git clone <repository-url>
cd example-voting-app
docker compose up
```

**Access the application:**
- Vote interface: [http://localhost:8080](http://localhost:8080)
- Results interface: [http://localhost:8081](http://localhost:8081)

## 🏗️ Architecture

![Architecture diagram](architecture.excalidraw.png)

### Components
- **Vote**: Python Flask web app for voting between two options
- **Redis**: In-memory data store for vote collection
- **Worker**: .NET Core service for vote processing
- **PostgreSQL**: Database for vote storage with Docker volume
- **Result**: Node.js web app for real-time results display

## 🔐 Security Pipeline

### Automated Security Scanning
The repository includes GitHub Actions workflows that automatically:

1. **Scan container images** for vulnerabilities on every push
2. **Validate Kubernetes manifests** for security misconfigurations
3. **Upload results** to GitHub Security tab
4. **Generate SARIF reports** for detailed analysis

### Security Results
- **GitHub Security Tab**: View all security findings
- **Pull Request Checks**: Automatic security validation
- **Artifacts**: Downloadable detailed scan reports

### Configuration
Security scanning requires these GitHub Secrets:
```
SYSDIG_SECURE_API_TOKEN: Your Sysdig API token
SYSDIG_SECURE_ENDPOINT: Your Sysdig endpoint URL
```

## 📋 Deployment Options

### Docker Swarm
```shell
# Initialize swarm (if needed)
docker swarm init

# Deploy the stack
docker stack deploy --compose-file docker-stack.yml vote
```

### Kubernetes
```shell
# Deploy all services
kubectl create -f k8s-specifications/

# Access services
# Vote: http://localhost:31000
# Result: http://localhost:31001

# Clean up
kubectl delete -f k8s-specifications/
```

## 📚 Documentation

- **[Security Integration Guide (Korean)](docs/sysdig-integration-guide-ko.md)**: Complete Sysdig v6 integration documentation
- **[Security Configurations](security/)**: Runtime policies, compliance configs, and security contexts

## 🛡️ Security Best Practices Implemented

### Container Security
- Non-root user execution
- Read-only root filesystems
- Security contexts with minimal privileges
- Resource limits and requests

### Network Security
- Network policies for service isolation
- Encrypted inter-service communication
- Minimal port exposure

### Infrastructure Security
- IaC security validation
- Compliance policy enforcement
- Continuous security monitoring

## 🔍 Security Findings Summary

Based on integrated Sysdig scanning:
- **Result Service**: Highest risk due to npm package vulnerabilities
- **Vote Service**: Medium risk with Python dependency concerns
- **Worker Service**: Lowest risk with .NET Core security
- **Infrastructure**: Secure with proper Kubernetes configurations

## 📈 Monitoring & Alerts

- **Real-time scanning**: Every commit triggers security analysis
- **Trend analysis**: Security posture tracking over time
- **Automated alerts**: Immediate notification of critical vulnerabilities
- **Compliance reporting**: Regular security status reports

---

**Note**: This is a demonstration application showcasing various technologies and security integration patterns. The security implementation follows Sysdig v6 best practices and is suitable for production reference.
