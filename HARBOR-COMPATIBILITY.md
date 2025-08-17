# Harbor Registry & Sysdig Scanner Compatibility Guide

## 🔧 Recent Changes for Compatibility

### OCI Index Issue Resolution

**Problem**: Sysdig Registry Scanner was failing to scan images with the error:
```
"OCI index found, but accept header does not support OCI indexes"
```

**Root Cause**: Multi-platform builds (`linux/amd64,linux/arm64`) create OCI Index manifests, which are not supported by the current Sysdig Registry Scanner version.

**Solution**: Modified all GitHub Actions workflows to use single-platform builds (`linux/amd64`).

### Modified Workflows

#### 1. **harbor-docker-build-vote.yaml**
- ✅ Changed from `platforms: linux/amd64,linux/arm64` to `platforms: linux/amd64`
- ✅ Added explicit `outputs` configuration for better compatibility
- ✅ Updated PR comments to reflect single-platform build

#### 2. **call-docker-build-worker.yaml**
- ✅ Changed from `platforms: linux/amd64,linux/arm64` to `platforms: linux/amd64`
- ✅ Added explicit `outputs` configuration for better compatibility
- ✅ Updated PR comments to reflect single-platform build

#### 3. **call-docker-build-result.yaml**
- ✅ Changed from `platforms: linux/amd64,linux/arm64` to `platforms: linux/amd64`
- ✅ Added explicit `outputs` configuration for better compatibility
- ✅ Updated PR comments to reflect single-platform build

#### 4. **sysdig-security-scan.yml**
- ✅ Added `--platform linux/amd64` to all Docker build commands
- ✅ Ensures consistent single-platform builds for scanning

### New Workflows

#### 5. **harbor-registry-scan.yaml** (NEW)
- 🆕 Dedicated workflow for scanning images already pushed to Harbor Registry
- 🆕 Triggered after successful builds or on schedule
- 🆕 Supports manual dispatch with service selection
- 🆕 Matrix strategy for parallel scanning of all services

#### 6. **integrated-build-scan.yaml** (NEW)
- 🆕 Intelligent change detection using `dorny/paths-filter`
- 🆕 Only builds and scans changed services
- 🆕 Combines Harbor Registry push with immediate security scanning
- 🆕 Optimized for CI/CD efficiency

## 📊 Scan Results Verification

After implementing these changes, the following images should now scan successfully:

### Previously Failing (Now Fixed)
- ❌ → ✅ `hw-harbor.bluesunnywings.com/sysdig-poc/vote:latest`
- ❌ → ✅ `hw-harbor.bluesunnywings.com/sysdig-poc/vote:main`
- ❌ → ✅ `hw-harbor.bluesunnywings.com/sysdig-poc/worker:latest`
- ❌ → ✅ `hw-harbor.bluesunnywings.com/sysdig-poc/worker:main`
- ❌ → ✅ `hw-harbor.bluesunnywings.com/sysdig-poc/result:latest`
- ❌ → ✅ `hw-harbor.bluesunnywings.com/sysdig-poc/result:main`

### Already Working
- ✅ `hw-harbor.bluesunnywings.com/library/alpine:latest`
- ✅ `hw-harbor.bluesunnywings.com/library/nginx:latest`

## 🔍 Monitoring & Verification

### 1. Registry Scanner Logs
```bash
# Check registry scanner logs
kubectl logs -n default -l app.kubernetes.io/name=registry-scanner

# Check specific scan job logs
kubectl logs registry-scanner-scan-on-start-xxxxx -n default
kubectl logs registry-scanner-worker-xxxxx -n default
```

### 2. Sysdig UI Verification
- Navigate to **Sysdig Secure** → **Vulnerabilities** → **Registry**
- Verify that Harbor Registry images appear in the scan results
- Check for successful scan status and vulnerability reports

### 3. GitHub Actions Verification
- Monitor workflow runs for successful builds and scans
- Check SARIF uploads to GitHub Security tab
- Review workflow artifacts for detailed scan results

## 🚀 Best Practices

### Docker Build Commands
```bash
# ✅ Correct - Single platform for Sysdig compatibility
docker build --platform linux/amd64 -t image:tag .

# ❌ Avoid - Multi-platform creates OCI Index
docker build --platform linux/amd64,linux/arm64 -t image:tag .
```

### GitHub Actions Configuration
```yaml
# ✅ Recommended configuration
- name: Build and push Docker image
  uses: docker/build-push-action@v5
  with:
    platforms: linux/amd64  # Single platform
    outputs: type=image,name=registry/project/image,push=true
```

## 🔄 Future Considerations

### Sysdig Scanner Updates
- Monitor Sysdig Registry Scanner releases for OCI Index support
- When OCI Index support is available, consider reverting to multi-platform builds
- Test compatibility with newer scanner versions

### Alternative Solutions
- Consider using Docker Manifest V2 explicitly
- Evaluate Harbor Registry settings for manifest format preferences
- Monitor Harbor Registry updates for better OCI compatibility

## 📞 Troubleshooting

### Common Issues
1. **"MANIFEST_UNKNOWN" errors**: Ensure single-platform builds
2. **Authentication failures**: Verify Harbor Registry credentials
3. **Network timeouts**: Check Harbor Registry accessibility from GitHub Actions

### Debug Commands
```bash
# Test Harbor Registry connectivity
curl -k https://hw-harbor.bluesunnywings.com/v2/_catalog

# Check image manifest format
docker manifest inspect hw-harbor.bluesunnywings.com/sysdig-poc/vote:latest

# Verify Sysdig CLI Scanner
sysdig-cli-scanner --help
```

---

**Last Updated**: August 17, 2025  
**Compatibility**: Sysdig Registry Scanner v0.8.2, Harbor Registry 2.x
