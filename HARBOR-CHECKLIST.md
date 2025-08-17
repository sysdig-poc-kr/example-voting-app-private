# 🚀 Harbor Registry 전환 - 빠른 체크리스트

## ⚡ 필수 작업 (순서대로 진행)

### ✅ 1. GitHub Secrets 설정
```bash
# GitHub 저장소 → Settings → Secrets and variables → Actions
HARBOR_USERNAME=<your-username>
HARBOR_PASSWORD=<your-password>
```

### ✅ 2. Harbor 접근 테스트
```bash
curl -I https://hw-harbor.bluesunnywings.com
# 응답: HTTP/2 200 OK 확인
```

### ✅ 3. 코드 푸시 & 빌드 확인
```bash
git push origin main
# GitHub Actions에서 3개 워크플로우 성공 확인:
# - Build Vote - Harbor Registry ✅
# - Build Worker - Harbor Registry ✅  
# - Build Result - Harbor Registry ✅
```

### ✅ 4. Harbor에서 이미지 확인
```bash
# https://hw-harbor.bluesunnywings.com → sysdig-poc 프로젝트
# 이미지 존재 확인:
# - vote:latest ✅
# - worker:latest ✅
# - result:latest ✅
```

### ✅ 5. Kubernetes Secret 생성
```bash
kubectl create secret docker-registry harbor-registry-secret \
  --docker-server=hw-harbor.bluesunnywings.com \
  --docker-username=<username> \
  --docker-password=<password> \
  --docker-email=<email>
```

### ✅ 6. 애플리케이션 배포
```bash
kubectl apply -f k8s-specifications/
```

### ✅ 7. 배포 확인
```bash
kubectl get pods
# 모든 Pod가 Running 상태 확인

kubectl port-forward service/vote 8080:80
kubectl port-forward service/result 8081:80
# 브라우저에서 localhost:8080, localhost:8081 접근 확인
```

---

## 🆘 문제 발생시

### ImagePullBackOff 에러
```bash
kubectl get secret harbor-registry-secret
# Secret 없으면 위의 5번 단계 재실행
```

### GitHub Actions 실패
```bash
# GitHub Secrets 재확인 (1번 단계)
# Harbor 프로젝트 sysdig-poc 존재 확인
```

### 이미지 없음 에러
```bash
# Harbor 웹 UI에서 sysdig-poc 프로젝트 생성
# GitHub Actions 재실행
```

---

## 📋 완료 체크

- [ ] GitHub Secrets 설정 완료
- [ ] Harbor 접근 확인 완료  
- [ ] GitHub Actions 빌드 성공
- [ ] Harbor 이미지 존재 확인
- [ ] Kubernetes Secret 생성 완료
- [ ] 애플리케이션 배포 완료
- [ ] 웹 접근 테스트 완료

**🎉 모든 체크 완료시 Harbor Registry 전환 성공!**

---

**📖 상세 가이드**: `docs/harbor-registry-setup.md` 참고
