# 🚀 Harbor Registry 전환 - 필수 설정 가이드

## ⚡ 빠른 시작 (필수 작업만)

### 1️⃣ GitHub Secrets 설정 (필수)
**위치**: GitHub 저장소 → Settings → Secrets and variables → Actions

```bash
HARBOR_USERNAME=<your-harbor-username>
HARBOR_PASSWORD=<your-harbor-password>
```

### 2️⃣ Harbor Registry 접근 확인 (필수)
```bash
# Harbor Registry 접근 테스트
curl -I https://hw-harbor.bluesunnywings.com
# 응답: HTTP/2 200 이면 정상
```

### 3️⃣ 코드 푸시하여 이미지 빌드 (필수)
```bash
git add .
git commit -m "Harbor Registry 전환"
git push origin main
```

### 4️⃣ Kubernetes Secret 생성 (배포 전 필수)
```bash
kubectl create secret docker-registry harbor-registry-secret \
  --docker-server=hw-harbor.bluesunnywings.com \
  --docker-username=<your-harbor-username> \
  --docker-password=<your-harbor-password> \
  --docker-email=<your-email>
```

### 5️⃣ 애플리케이션 배포 (필수)
```bash
kubectl apply -f k8s-specifications/
```

---

## 🔍 다음 단계별 상세 가이드

### 📋 Step 1: GitHub Actions 확인
**목적**: Harbor Registry로 이미지가 정상 빌드되는지 확인

1. GitHub 저장소 → Actions 탭 이동
2. 최신 워크플로우 실행 상태 확인:
   - ✅ `Build Vote - Harbor Registry`
   - ✅ `Build Worker - Harbor Registry`  
   - ✅ `Build Result - Harbor Registry`

**문제 발생시**: [트러블슈팅 섹션](#-트러블슈팅) 참고

### 📋 Step 2: Harbor Registry에서 이미지 확인
**목적**: 빌드된 이미지가 Harbor에 정상 푸시되었는지 확인

1. Harbor 웹 UI 접속: `https://hw-harbor.bluesunnywings.com`
2. `sysdig-poc` 프로젝트 확인
3. 다음 이미지들이 존재하는지 확인:
   - `vote:latest`
   - `worker:latest`
   - `result:latest`

### 📋 Step 3: Kubernetes 배포 확인
**목적**: Harbor 이미지로 정상 배포되는지 확인

```bash
# 1. Pod 상태 확인
kubectl get pods -o wide

# 2. 이미지 Pull 상태 확인 (문제 발생시)
kubectl describe pod <pod-name>

# 3. 서비스 접근 테스트
kubectl port-forward service/vote 8080:80
kubectl port-forward service/result 8081:80
```

**예상 결과**:
- 모든 Pod가 `Running` 상태
- 브라우저에서 `localhost:8080` (투표), `localhost:8081` (결과) 접근 가능

---

## 🆘 트러블슈팅

### ❌ GitHub Actions 빌드 실패
**증상**: 워크플로우가 빨간색으로 실패
**원인**: Harbor Registry 인증 실패
**해결**:
```bash
# GitHub Secrets 재확인
# Settings → Secrets → HARBOR_USERNAME, HARBOR_PASSWORD 값 확인
```

### ❌ ImagePullBackOff 에러
**증상**: Pod가 `ImagePullBackOff` 상태
**원인**: Kubernetes에서 Harbor 이미지를 가져올 수 없음
**해결**:
```bash
# 1. Secret 존재 확인
kubectl get secret harbor-registry-secret

# 2. Secret이 없으면 생성
kubectl create secret docker-registry harbor-registry-secret \
  --docker-server=hw-harbor.bluesunnywings.com \
  --docker-username=<username> \
  --docker-password=<password> \
  --docker-email=<email>

# 3. Pod 재시작
kubectl rollout restart deployment/vote
kubectl rollout restart deployment/worker
kubectl rollout restart deployment/result
```

### ❌ 이미지를 찾을 수 없음
**증상**: `repository does not exist` 에러
**원인**: Harbor에 이미지가 푸시되지 않음
**해결**:
1. GitHub Actions 로그 확인
2. Harbor 프로젝트 `sysdig-poc` 존재 확인
3. 필요시 Harbor에서 프로젝트 생성

---

## 📊 변경사항 요약

### 🔄 이미지 경로 변경
| 서비스 | 기존 경로 | 새로운 경로 |
|--------|-----------|-------------|
| Vote | `dockersamples/examplevotingapp_vote` | `hw-harbor.bluesunnywings.com/sysdig-poc/vote:latest` |
| Worker | `dockersamples/examplevotingapp_worker` | `hw-harbor.bluesunnywings.com/sysdig-poc/worker:latest` |
| Result | `dockersamples/examplevotingapp_result` | `hw-harbor.bluesunnywings.com/sysdig-poc/result:latest` |

### 📝 수정된 파일들
- `.github/workflows/call-docker-build-*.yaml` (3개 파일)
- `k8s-specifications/*-deployment.yaml` (4개 파일)
- `docker-compose.images.yml`

---

## 📚 참고 정보 (선택사항)

<details>
<summary>🔧 고급 설정 옵션</summary>

### Harbor Registry 보안 정책
```yaml
# Harbor 프로젝트 보안 설정 (참고용)
vulnerability_scanning: true
prevent_vulnerable_images: true
automatically_scan_images_on_push: true
severity_level: "High"
```

### 멀티 네임스페이스 배포
```bash
# voting-app 네임스페이스용 (보안 버전)
kubectl create namespace voting-app
kubectl create secret docker-registry harbor-registry-secret \
  --docker-server=hw-harbor.bluesunnywings.com \
  --docker-username=<username> \
  --docker-password=<password> \
  --docker-email=<email> \
  --namespace=voting-app
```

### Docker Compose로 로컬 테스트
```bash
# Harbor 이미지로 로컬 실행 (Harbor 로그인 필요)
docker login hw-harbor.bluesunnywings.com
docker-compose -f docker-compose.images.yml up
```

</details>

<details>
<summary>🔄 롤백 방법</summary>

### 긴급 롤백 (기존 Docker Hub 이미지로)
```bash
kubectl set image deployment/vote vote=dockersamples/examplevotingapp_vote:latest
kubectl set image deployment/worker worker=dockersamples/examplevotingapp_worker:latest  
kubectl set image deployment/result result=dockersamples/examplevotingapp_result:latest
```

</details>

<details>
<summary>📊 모니터링 및 메트릭</summary>

### Harbor Registry 메트릭
- 이미지 풀 횟수
- 스토리지 사용량  
- 취약점 스캔 결과

### Sysdig 통합 상태
Harbor Registry의 이미지들도 기존과 동일하게 Sysdig 보안 스캔이 적용됩니다.

</details>

---

## ✅ 체크리스트

완료된 항목에 체크하세요:

- [ ] GitHub Secrets 설정 (`HARBOR_USERNAME`, `HARBOR_PASSWORD`)
- [ ] Harbor Registry 접근 확인
- [ ] 코드 푸시 및 GitHub Actions 빌드 성공 확인
- [ ] Harbor에서 이미지 존재 확인
- [ ] Kubernetes Secret 생성
- [ ] 애플리케이션 배포 및 동작 확인
- [ ] 투표 앱 접근 테스트 (localhost:8080, localhost:8081)

**🎉 모든 항목이 완료되면 Harbor Registry 전환이 성공적으로 완료됩니다!**

---

**📧 문의사항**: Harbor Registry 관련 이슈가 있으시면 언제든 연락주세요!
