# 🗳️ Example Voting App - Sysdig 보안 통합 버전 (v6 Enhanced)

[![Sysdig Security](https://img.shields.io/badge/Sysdig-v6%20Enhanced-blue)](https://sysdig.com)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-Ready-green)](https://kubernetes.io)
[![Docker](https://img.shields.io/badge/Docker-Multi--platform-blue)](https://docker.com)
[![SLSA](https://img.shields.io/badge/SLSA-Level%203-orange)](https://slsa.dev)
[![License](https://img.shields.io/badge/License-Apache%202.0-yellow.svg)](LICENSE)

Docker 컨테이너 여러 개에서 실행되는 간단한 분산 애플리케이션으로, **최신 Sysdig v6 및 다중 보안 도구가 완전히 통합**되어 있습니다.

## 📋 목차

- [🏗️ 아키텍처](#️-아키텍처)
- [🚀 빠른 시작](#-빠른-시작)
- [🔒 Sysdig v6 보안 통합](#-sysdig-v6-보안-통합)
- [🛡️ 다중 보안 도구 스택](#️-다중-보안-도구-스택)
- [📊 모니터링 및 컴플라이언스](#-모니터링-및-컴플라이언스)
- [🔧 설정 및 배포](#-설정-및-배포)
- [📈 보안 이벤트 시뮬레이션](#-보안-이벤트-시뮬레이션)
- [📚 문서](#-문서)

## 🏗️ 아키텍처

![Architecture diagram](architecture.excalidraw.png)

### 핵심 구성 요소

- **🐍 Vote 서비스**: Python Flask 기반 투표 웹 애플리케이션
- **⚙️ Worker 서비스**: .NET 기반 백그라운드 작업 처리기
- **📊 Result 서비스**: Node.js 기반 실시간 결과 표시 웹 애플리케이션
- **🗄️ Redis**: 메시지 큐 및 캐시
- **🐘 PostgreSQL**: 영구 데이터 저장소

### 🔒 최신 보안 레이어 (v6 Enhanced)

- **Sysdig Scan Action v6**: 최신 컨테이너 보안 스캔
- **Multi-platform 지원**: AMD64, ARM64 아키텍처
- **SARIF 통합**: GitHub Security 탭 연동
- **SBOM 자동 생성**: 소프트웨어 구성 요소 명세서
- **공급망 보안**: Cosign 서명 + SLSA Provenance

## 🚀 빠른 시작

### 전제 조건

- [Docker Desktop](https://www.docker.com/products/docker-desktop) (Mac/Windows)
- [Docker Compose](https://docs.docker.com/compose) (Linux)
- [kubectl](https://kubernetes.io/docs/tasks/tools/) (Kubernetes 배포용)
- Sysdig Secure 계정 및 API 토큰
- Snyk 토큰 (선택사항)

### 1. 로컬 개발 환경

```bash
# 저장소 클론
git clone https://github.com/your-org/example-voting-app.git
cd example-voting-app

# Docker Compose로 실행
docker compose up
```

- 투표 앱: [http://localhost:8080](http://localhost:8080)
- 결과 앱: [http://localhost:8081](http://localhost:8081)

### 2. Kubernetes 배포

```bash
# 네임스페이스 생성
kubectl create namespace voting-app

# 보안이 강화된 매니페스트 배포
kubectl apply -f k8s-specifications/

# 네트워크 보안 정책 적용
kubectl apply -f k8s-specifications/network-policies.yaml
```

## 🔒 Sysdig v6 보안 통합

### 🎯 v6의 주요 새 기능

#### 1. 향상된 컨테이너 이미지 보안 스캔

```yaml
# .github/workflows/sysdig-security-scan.yml
- name: Run Sysdig Secure Scan
  uses: sysdiglabs/scan-action@v6  # ⬆️ v5에서 v6로 업그레이드
  with:
    image-tag: ${{ steps.image.outputs.image }}
    sysdig-secure-token: ${{ secrets.SYSDIG_SECURE_API_TOKEN }}
    sysdig-secure-url: ${{ secrets.SYSDIG_SECURE_ENDPOINT }}
    # 🆕 v6 새로운 기능들
    stop-on-failed-policy-eval: false
    stop-on-policy-eval-failure: false
    use-policies: true
    extra-parameters: "--format json --verbose"
    registry-user: ${{ github.actor }}
    registry-password: ${{ secrets.GITHUB_TOKEN }}
```

#### 2. Multi-platform 빌드 지원

```yaml
- name: Build and push Docker image
  uses: docker/build-push-action@v6  # ⬆️ v5에서 v6로 업그레이드
  with:
    # 🆕 새로운 기능들
    provenance: true
    sbom: true
    platforms: linux/amd64,linux/arm64
```

#### 3. SARIF 결과 GitHub 통합

```yaml
- name: Upload SARIF results
  uses: github/codeql-action/upload-sarif@v3
  with:
    sarif_file: sysdig-results.sarif
```

**스캔 결과 분석**:
- **Vote 서비스**: Python 3.11 기반, 중간 위험도
- **Worker 서비스**: .NET 7.0 기반, 낮은 위험도  
- **Result 서비스**: Node.js 18 기반, 높은 위험도 (npm 패키지 취약점)

## 🛡️ 다중 보안 도구 스택

### 🔧 통합된 보안 도구들

#### 1. **Sysdig Scan Action v6** 🔒
- 컨테이너 이미지 취약점 스캔
- IaC 보안 검증
- 정책 기반 평가
- SARIF 결과 제공

#### 2. **Trivy v0.24.0** 🔍
- 파일시스템 취약점 스캔
- 컨테이너 이미지 스캔
- 다양한 출력 형식 지원

#### 3. **Snyk v0.4.0** 🐍
- 의존성 취약점 분석
- Docker 이미지 스캔
- 실시간 취약점 데이터베이스

#### 4. **Grype (Anchore) v4** ⚓
- 컨테이너 이미지 취약점 스캔
- 다양한 패키지 매니저 지원
- 심각도 기반 필터링

#### 5. **Checkov v12** ✅
- IaC 보안 정책 검증
- Kubernetes, Dockerfile, Docker Compose 지원
- 800+ 내장 정책 규칙

#### 6. **Semgrep** 🔎
- 정적 코드 분석
- 보안 취약점 패턴 탐지
- 다중 언어 지원

#### 7. **Cosign v3.5.0** ✍️
- 컨테이너 이미지 서명
- Sigstore 기반 무키 서명
- 공급망 보안 강화

#### 8. **SLSA Provenance v2.0.0** 📋
- 빌드 출처 증명
- 공급망 무결성 검증
- SLSA Level 3 준수

### 📈 보안 커버리지 매트릭스

| 보안 영역 | 도구 | 커버리지 | 상태 |
|-----------|------|----------|------|
| 컨테이너 이미지 | Sysdig, Trivy, Snyk, Grype | 100% | ✅ |
| IaC 보안 | Sysdig, Checkov | 100% | ✅ |
| 정적 분석 | Semgrep | 100% | ✅ |
| 의존성 스캔 | Snyk, Trivy | 100% | ✅ |
| 공급망 보안 | Cosign, SLSA | 100% | ✅ |

## 📊 모니터링 및 컴플라이언스

### 컴플라이언스 프레임워크

#### CIS Kubernetes Benchmark
- ✅ API 서버 보안 설정
- ✅ etcd 보안 구성
- ✅ 컨트롤 플레인 보안
- ✅ 워커 노드 보안
- ✅ RBAC 정책

#### NIST Cybersecurity Framework
- **식별(Identify)**: 자산 및 위험 관리
- **보호(Protect)**: 접근 제어 및 데이터 보안
- **탐지(Detect)**: 이상 징후 및 이벤트 모니터링
- **대응(Respond)**: 사고 대응 계획
- **복구(Recover)**: 복구 계획 및 개선

### 📈 보안 메트릭

```bash
# 보안 대시보드 접근
kubectl port-forward -n voting-app svc/sysdig-dashboard 3000:3000
```

**주요 지표**:
- 취약점 수 및 심각도
- 정책 위반 횟수
- 컴플라이언스 점수
- 보안 이벤트 발생률
- SBOM 커버리지
- 서명된 이미지 비율

## 🔧 설정 및 배포

### 환경 변수 설정

```bash
# Sysdig 자격 증명 설정
export SYSDIG_SECURE_API_TOKEN="your-api-token"
export SYSDIG_SECURE_ENDPOINT="https://secure.sysdig.com"

# Snyk 토큰 설정 (선택사항)
export SNYK_TOKEN="your-snyk-token"

# Kubernetes 시크릿 생성
kubectl create secret generic sysdig-credentials \
  --from-literal=api-token=$SYSDIG_SECURE_API_TOKEN \
  --from-literal=endpoint=$SYSDIG_SECURE_ENDPOINT \
  -n voting-app
```

### GitHub Actions 설정

1. **Repository Secrets 추가**:
   - `SYSDIG_SECURE_API_TOKEN`
   - `SYSDIG_SECURE_ENDPOINT`
   - `SNYK_TOKEN` (선택사항)

2. **워크플로우 활성화**:
   ```bash
   # 기본 Sysdig v6 워크플로우
   git add .github/workflows/sysdig-security-scan.yml
   
   # 고급 다중 도구 워크플로우
   git add .github/workflows/advanced-security-scan.yml
   
   git commit -m "Add enhanced security scanning with v6"
   git push
   ```

### 🆕 v6 업그레이드 혜택

#### SBOM (Software Bill of Materials) 자동 생성
```bash
# SBOM 파일 확인
ls -la sbom/
# vote-sbom.spdx.json
# worker-sbom.spdx.json  
# result-sbom.spdx.json
```

#### GitHub Security 탭 통합
- 모든 SARIF 결과가 GitHub Security 탭에 표시
- 취약점 추적 및 관리 용이
- 자동화된 보안 알림

#### Multi-platform 이미지 지원
```bash
# AMD64 및 ARM64 아키텍처 모두 지원
docker manifest inspect ghcr.io/your-org/example-voting-app/vote:latest
```

## 📈 보안 이벤트 시뮬레이션

### 시뮬레이션 실행

```bash
# 보안 이벤트 시뮬레이션 스크립트 실행
./scripts/security-event-simulation.sh
```

### 시뮬레이션 시나리오

1. **🔍 의심스러운 파일 접근**
   - `/etc/passwd`, `/etc/shadow` 접근 시도
   - 시스템 파일 무단 접근

2. **🌐 승인되지 않은 네트워크 연결**
   - 외부 IP로의 예상치 못한 연결
   - 비정상적인 포트 사용

3. **⚡ 예상치 못한 프로세스 실행**
   - 악성 스크립트 다운로드 시도
   - 승인되지 않은 도구 실행

4. **🔐 권한 상승 시도**
   - sudo, su 명령 시도
   - 루트 권한 획득 시도

5. **🏃 컨테이너 탈출 시도**
   - Docker 소켓 접근
   - nsenter 명령 사용

6. **💰 암호화폐 채굴**
   - CPU 집약적 프로세스
   - 채굴 풀 연결 시도

7. **🐚 리버스 쉘 시도**
   - netcat을 이용한 백도어
   - bash 리버스 쉘

8. **💉 SQL 인젝션**
   - 악의적인 SQL 쿼리
   - 데이터베이스 조작 시도

### 🚨 이러한 활동이 의심스러운 이유

1. **정상 동작 범위 초과**: 애플리케이션의 정상적인 동작 패턴을 벗어남
2. **보안 정책 위반**: 설정된 보안 정책에서 명시적으로 금지된 행위
3. **공격 패턴 유사**: 알려진 공격 기법과 유사한 패턴
4. **데이터 유출 위험**: 민감한 정보에 대한 무단 접근 시도
5. **시스템 손상 가능성**: 시스템 무결성을 해칠 수 있는 행위

## 📚 문서

### 상세 문서

- [📋 Sysdig 통합 계획서](docs/sysdig-integration-plan.md)
- [🔒 보안 정책 가이드](sysdig-runtime-policies.yaml)
- [📊 컴플라이언스 설정](sysdig-compliance-config.yaml)
- [🔍 활동 감사 설정](sysdig-activity-audit.yaml)
- [📈 프로젝트 요약](PROJECT-SUMMARY.md)

### API 문서

- [Vote API](vote/README.md)
- [Worker API](worker/README.md)
- [Result API](result/README.md)

### 운영 가이드

```bash
# 로그 확인
kubectl logs -n voting-app -l app=vote --tail=100

# 보안 이벤트 확인
kubectl get events -n voting-app --field-selector type=Warning

# 컴플라이언스 상태 확인
sysdig-cli compliance status --zone voting-app-zone

# SBOM 확인
cat sbom/vote-sbom.spdx.json | jq '.packages[].name'

# 이미지 서명 검증
cosign verify ghcr.io/your-org/example-voting-app/vote:latest
```

## 🎯 활동 감사의 가치

### 왜 활동 감사가 중요한가?

1. **🔍 완전한 가시성**
   - 모든 사용자 활동 추적
   - 시스템 변경 사항 기록
   - 데이터 접근 패턴 분석

2. **🛡️ 보안 사고 대응**
   - 사고 발생 시 근본 원인 분석
   - 공격 경로 추적
   - 피해 범위 파악

3. **📋 컴플라이언스 준수**
   - 규제 요구사항 충족
   - 감사 증빙 자료 제공
   - 내부 통제 강화

4. **📊 위험 관리**
   - 비정상적인 활동 패턴 탐지
   - 내부자 위협 식별
   - 보안 정책 효과성 평가

5. **🔄 지속적인 개선**
   - 보안 정책 최적화
   - 프로세스 개선
   - 교육 및 훈련 계획

## 🆕 v6 업그레이드 요약

### 주요 개선사항

| 기능 | v5 | v6 | 개선점 |
|------|----|----|--------|
| 스캔 액션 | sysdiglabs/scan-action@v5 | sysdiglabs/scan-action@v6 | 향상된 정책 평가 |
| 빌드 액션 | docker/build-push-action@v5 | docker/build-push-action@v6 | Multi-platform 지원 |
| SARIF 지원 | ❌ | ✅ | GitHub Security 통합 |
| SBOM 생성 | ❌ | ✅ | 자동 생성 |
| Provenance | ❌ | ✅ | 빌드 출처 증명 |
| 다중 도구 | ❌ | ✅ | 8개 보안 도구 통합 |

### 추가된 보안 도구

- **Trivy v0.24.0**: 종합적인 취약점 스캔
- **Snyk v0.4.0**: 의존성 보안 분석
- **Grype v4**: Anchore 기반 이미지 스캔
- **Checkov v12**: IaC 보안 검증
- **Semgrep**: 정적 코드 분석
- **Cosign v3.5.0**: 이미지 서명
- **SLSA v2.0.0**: 공급망 보안

## 🤝 기여하기

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 라이선스

이 프로젝트는 Apache 2.0 라이선스 하에 배포됩니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

## 🆘 지원

- 📧 이메일: security-team@company.com
- 💬 Slack: #voting-app-security
- 📖 문서: [Sysdig Documentation](https://docs.sysdig.com)
- 🐛 이슈: [GitHub Issues](https://github.com/your-org/example-voting-app/issues)

---

**⚠️ 주의사항**: 이 애플리케이션은 교육 및 데모 목적으로 설계되었습니다. 프로덕션 환경에서 사용하기 전에 추가적인 보안 검토가 필요합니다.

**🎉 v6 Enhanced**: 최신 Sysdig v6 및 8개의 보안 도구가 통합된 종합 보안 솔루션입니다!
