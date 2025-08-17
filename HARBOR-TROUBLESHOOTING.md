# Harbor Registry 연결 문제 해결 가이드

## 🚨 발생한 문제

```
Error response from daemon: Get "https://hw-harbor.bluesunnywings.com/v2/": unauthorized
```

## 🔍 문제 원인 분석

### 1. GitHub Secrets 확인 필요
다음 Secrets가 올바르게 설정되어 있는지 확인:
- `HARBOR_USERNAME`
- `HARBOR_PASSWORD`

### 2. Harbor Registry 사용자 권한 확인
- Harbor에서 해당 사용자가 `sysdig-poc` 프로젝트에 접근 권한이 있는지 확인
- 최소 `Developer` 또는 `Maintainer` 권한 필요

### 3. Robot Account 사용 권장
일반 사용자 계정 대신 Robot Account 사용을 권장합니다.

## 🛠️ 해결 방법

### 방법 1: GitHub Secrets 재설정

1. **GitHub Repository → Settings → Secrets and variables → Actions**
2. 다음 Secrets 확인/추가:
   ```
   HARBOR_USERNAME: admin (또는 Robot Account 이름)
   HARBOR_PASSWORD: 실제 비밀번호 (또는 Robot Token)
   ```

### 방법 2: Harbor Robot Account 생성 (권장)

1. **Harbor UI 접속**: https://hw-harbor.bluesunnywings.com
2. **Projects → sysdig-poc → Robot Accounts**
3. **New Robot Account** 클릭
4. 설정:
   ```
   Name: github-actions-robot
   Expiration: Never (또는 적절한 기간)
   Description: GitHub Actions CI/CD
   Permissions: Push and Pull
   ```
5. 생성된 Robot Account 정보를 GitHub Secrets에 저장:
   ```
   HARBOR_USERNAME: robot$github-actions-robot
   HARBOR_PASSWORD: [생성된 토큰]
   ```

### 방법 3: Harbor Registry 연결 테스트

로컬에서 연결 테스트:
```bash
# 기본 연결 테스트
curl -k https://hw-harbor.bluesunnywings.com/v2/

# 인증 테스트
docker login hw-harbor.bluesunnywings.com
Username: [HARBOR_USERNAME]
Password: [HARBOR_PASSWORD]

# 프로젝트 접근 테스트
docker pull hw-harbor.bluesunnywings.com/sysdig-poc/alpine:latest
```

## 🔧 워크플로우 개선사항

### 에러 처리 강화
- Harbor 로그인 실패 시 워크플로우가 계속 진행되도록 `continue-on-error: true` 추가
- 로그인 상태 확인 단계 추가
- 푸시 단계에서 로그인 성공 여부 확인

### SARIF 파일 문제 해결
- SARIF 파일 존재 여부 확인 후 업로드
- 파일이 없을 경우 경고 메시지 출력
- `if-no-files-found: ignore`로 설정하여 에러 방지

## 📋 체크리스트

### Harbor Registry 설정
- [ ] Harbor Registry 접근 가능 확인
- [ ] 사용자 계정 또는 Robot Account 생성
- [ ] `sysdig-poc` 프로젝트 권한 확인
- [ ] Docker 로그인 테스트 완료

### GitHub Secrets 설정
- [ ] `HARBOR_USERNAME` 설정 확인
- [ ] `HARBOR_PASSWORD` 설정 확인
- [ ] `SYSDIG_SECURE_API_TOKEN` 설정 확인
- [ ] `SYSDIG_SECURE_ENDPOINT` 설정 확인

### 워크플로우 테스트
- [ ] PR 생성하여 빌드/스캔 테스트
- [ ] main 브랜치 푸시하여 Harbor 푸시 테스트
- [ ] SARIF 파일 업로드 확인
- [ ] GitHub Security 탭에서 결과 확인

## 🚀 권장 설정

### GitHub Secrets 최종 설정
```
HARBOR_USERNAME=robot$github-actions-robot
HARBOR_PASSWORD=[Robot Account Token]
SYSDIG_SECURE_API_TOKEN=[Sysdig API Token]
SYSDIG_SECURE_ENDPOINT=https://app.us4.sysdig.com
```

### Harbor Robot Account 권한
- **Project**: sysdig-poc
- **Permissions**: Push and Pull artifacts
- **Expiration**: 1 year (또는 조직 정책에 따라)

## 🔍 디버깅 명령어

### Harbor Registry 상태 확인
```bash
# Registry API 응답 확인
curl -k -I https://hw-harbor.bluesunnywings.com/v2/

# 프로젝트 목록 확인 (인증 후)
curl -k -u "username:password" https://hw-harbor.bluesunnywings.com/api/v2.0/projects

# 특정 프로젝트의 Repository 확인
curl -k -u "username:password" https://hw-harbor.bluesunnywings.com/api/v2.0/projects/sysdig-poc/repositories
```

### Docker 명령어 테스트
```bash
# 로그인 테스트
docker login hw-harbor.bluesunnywings.com

# 이미지 푸시 테스트
docker tag alpine:latest hw-harbor.bluesunnywings.com/sysdig-poc/test:latest
docker push hw-harbor.bluesunnywings.com/sysdig-poc/test:latest

# 이미지 풀 테스트
docker pull hw-harbor.bluesunnywings.com/sysdig-poc/test:latest
```

---

**참고**: 이 문제가 해결되면 모든 서비스 (vote, worker, result)가 정상적으로 Harbor Registry에 푸시되고 Sysdig에서 스캔될 것입니다.
