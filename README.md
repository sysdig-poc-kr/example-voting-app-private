# Voting App with Sysdig Security

A microservices voting application with integrated security scanning using Sysdig.

## Architecture

- **Vote**: Python Flask frontend
- **Worker**: .NET Core background processor  
- **Result**: Node.js results display
- **Database**: PostgreSQL + Redis

## Security Integration

### Container Security
- Automated vulnerability scanning with Sysdig
- Harbor Registry integration
- SARIF reports to GitHub Security

### Infrastructure Security  
- Kubernetes manifest scanning
- Network policy validation
- Security context analysis

## CI/CD Pipelines

Each service has an independent pipeline:

- `vote.yaml` - Vote service build, scan & push
- `worker.yaml` - Worker service build, scan & push  
- `result.yaml` - Result service build, scan & push
- `iac.yaml` - Infrastructure security scanning

### Pipeline Features
- Path-based triggering (only changed services build)
- Docker build with `linux/amd64` platform
- Sysdig security scanning
- Harbor Registry push (main/develop branches)
- GitHub Security integration

## Configuration

### Required Secrets
```
HARBOR_USERNAME         # Harbor Registry username
HARBOR_PASSWORD         # Harbor Registry password
SYSDIG_SECURE_API_TOKEN # Sysdig API token
SYSDIG_SECURE_ENDPOINT  # https://app.us4.sysdig.com
```

### Harbor Registry
- Registry: `hw-harbor.bluesunnywings.com`
- Project: `sysdig-poc`

## Development

### Local Development
```bash
docker-compose up
```

### Kubernetes Deployment
```bash
kubectl apply -f k8s-specifications/
```

## Security Scanning

### Container Images
- Medium+ severity vulnerability detection
- Policy evaluation against security benchmarks
- SBOM generation and analysis

### Infrastructure
- Kubernetes security best practices
- Network policy validation
- Resource limit enforcement
- RBAC configuration review

## Monitoring

- Sysdig Secure Console: Complete security analysis
- GitHub Security: SARIF vulnerability reports
- Harbor Registry: Image vulnerability status
