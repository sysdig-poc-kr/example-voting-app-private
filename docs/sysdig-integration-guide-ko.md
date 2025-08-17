# Sysdig v6 보안 통합 가이드

## 📋 개요

이 가이드는 example-voting-app에 Sysdig v6 보안 플랫폼을 통합하여 완전한 DevSecOps 파이프라인을 구현하는 방법을 설명합니다. Amazon EKS 배포를 위한 컨테이너 이미지 취약점 스캔, Infrastructure as Code (IaC) 보안 검증, GitHub Security 연동을 포함합니다.

## 🔧 구현된 보안 기능

### 1. 자동화된 보안 파이프라인
- **워크플로우 파일**: `.github/workflows/sysdig-security-scan.yml`
- **트리거 조건**: 
  - Push to main/develop 브랜치
  - Pull Request to main 브랜치
- **실행 방식**: 4개 독립적인 병렬 보안 스캔 작업

### 2. 보안 스캔 매트릭스

#### Infrastructure as Code (IaC) 스캔
```yaml
대상: k8s-specifications/ 디렉토리
검증 항목:
  - 보안 컨텍스트 설정
  - 네트워크 정책 구성
  - 리소스 제한 및 할당량
  - 시크릿 관리 방식
최소 심각도: Medium 이상
결과 위치: Sysdig Secure Console
```

#### 컨테이너 이미지 스캔
| 서비스 | 기술 스택 | 위험도 평가 | 스캔 대상 | GitHub Security |
|--------|-----------|-------------|-----------|-----------------|
| **Vote** | Python Flask | 🟡 중간 | OS 패키지, Python 의존성 | ✅ SARIF 리포트 |
| **Worker** | .NET Core | 🟢 낮음 | OS 패키지, .NET 의존성 | ✅ SARIF 리포트 |
| **Result** | Node.js | 🔴 높음 | OS 패키지, npm 패키지 | ✅ SARIF 리포트 |

### 3. 이중 보고 시스템

#### GitHub Security 탭 (SARIF 기반)
- **컨테이너 이미지 취약점**: 표준화된 SARIF 형식으로 보고
- **개발자 친화적**: Pull Request 내 직접 피드백
- **추적 가능**: 취약점 상태 변화 히스토리

#### Sysdig Secure Console (종합 분석)
- **IaC 정책 검증**: Kubernetes 보안 설정 분석
- **정책 준수**: 엔터프라이즈 보안 표준 검증
- **런타임 모니터링**: 배포 후 지속적인 보안 감시

## 🚀 설정 가이드

### 1. GitHub Secrets 구성

GitHub 저장소 Settings → Secrets and variables → Actions에서 다음 시크릿을 추가하세요:

```bash
# 필수 Sysdig 자격 증명
SYSDIG_SECURE_API_TOKEN=<your-sysdig-api-token>
SYSDIG_SECURE_ENDPOINT=<your-sysdig-endpoint>

# 예시 엔드포인트
# US East: https://secure.sysdig.com
# US West: https://us2.app.sysdig.com
# EU: https://eu1.app.sysdig.com
```

### 2. Sysdig API 토큰 생성

1. **Sysdig Secure Console 로그인**
2. **Settings → User Profile → API Tokens**
3. **"Create API Token" 클릭**
4. **토큰 이름 입력** (예: "GitHub-Actions-Integration")
5. **권한 설정**: `Secure Scanning` 권한 필요
6. **토큰 복사 및 GitHub Secrets에 저장**

### 3. 워크플로우 활성화 확인

```bash
# 저장소 클론 후 워크플로우 파일 확인
git clone <repository-url>
cd example-voting-app-private
ls -la .github/workflows/

# 예상 출력:
# sysdig-security-scan.yml
# call-docker-build-*.yaml
```

## 📊 보안 결과 해석

### GitHub Security 탭에서 확인할 수 있는 정보

#### 취약점 심각도 분류
- **Critical**: 즉시 수정 필요 (CVSS 9.0-10.0)
- **High**: 우선 수정 권장 (CVSS 7.0-8.9)
- **Medium**: 계획된 수정 (CVSS 4.0-6.9)
- **Low**: 모니터링 필요 (CVSS 0.1-3.9)

#### 취약점 정보 상세
```yaml
각 취약점별 제공 정보:
  - CVE 번호 및 설명
  - 영향받는 패키지 및 버전
  - 수정 가능한 버전 정보
  - CVSS 점수 및 벡터
  - 참조 링크 (NVD, 보안 권고)
```

### Sysdig Console에서 확인할 수 있는 정보

#### IaC 정책 검증 결과
- **정책 위반 항목**: 구체적인 보안 설정 문제
- **권장 수정 방안**: 실행 가능한 해결책
- **컴플라이언스 점수**: 전체적인 보안 준수 수준
- **벤치마크 비교**: CIS, NIST 등 표준 대비 평가

## 🛠️ 문제 해결

### 일반적인 문제 및 해결책

#### 1. API 토큰 인증 실패
```bash
# 증상: "Authentication failed" 오류
# 해결책:
1. API 토큰 유효성 확인
2. 엔드포인트 URL 정확성 검증
3. 토큰 권한 설정 확인 (Secure Scanning 권한 필요)
```

#### 2. 스캔 시간 초과
```bash
# 증상: 워크플로우가 시간 초과로 실패
# 해결책:
1. 이미지 크기 최적화 (multi-stage build 사용)
2. 불필요한 패키지 제거
3. 스캔 타임아웃 설정 조정
```

#### 3. SARIF 업로드 실패
```bash
# 증상: GitHub Security 탭에 결과가 표시되지 않음
# 해결책:
1. GitHub Actions 권한 확인 (security-events: write)
2. SARIF 파일 형식 검증
3. 저장소 보안 기능 활성화 확인
```

## 📈 보안 메트릭 모니터링

### 주요 성과 지표 (KPI)

#### 보안 품질 메트릭
- **취약점 발견율**: 새로운 취약점 식별 속도
- **수정 시간 (MTTR)**: 취약점 발견부터 수정까지 소요 시간
- **정책 준수율**: IaC 보안 정책 준수 비율
- **보안 커버리지**: 스캔 대상 자산 비율

#### 운영 효율성 메트릭
- **자동화율**: 수동 개입 없이 처리되는 보안 검사 비율
- **거짓 양성률**: 실제 위험이 아닌 알림 비율
- **개발자 생산성**: 보안 검사로 인한 개발 지연 시간

## 🔄 지속적인 개선

### 정기적인 검토 항목

#### 월간 보안 리뷰
- [ ] 취약점 트렌드 분석
- [ ] 정책 효과성 평가
- [ ] 새로운 보안 위협 대응
- [ ] 팀 보안 교육 계획

#### 분기별 시스템 업데이트
- [ ] Sysdig 플랫폼 업데이트 적용
- [ ] 보안 정책 규칙 업데이트
- [ ] 워크플로우 최적화
- [ ] 성능 벤치마크 측정

## 🎯 모범 사례

### 개발팀을 위한 권장사항

#### 보안 우선 개발
1. **Shift-Left 보안**: 개발 초기 단계부터 보안 고려
2. **정기적인 의존성 업데이트**: 알려진 취약점 사전 방지
3. **보안 코드 리뷰**: 동료 검토 시 보안 관점 포함
4. **보안 교육**: 최신 보안 위협 및 대응 방법 학습

#### CI/CD 파이프라인 최적화
1. **병렬 스캔**: 빌드 시간 단축을 위한 병렬 보안 검사
2. **점진적 배포**: 보안 검증 통과 후 단계적 배포
3. **롤백 계획**: 보안 문제 발견 시 즉시 롤백 가능한 체계
4. **모니터링 통합**: 배포 후 지속적인 보안 상태 감시

---

**🔒 이 가이드를 통해 엔터프라이즈급 보안 표준을 달성하고 지속적인 보안 개선을 실현하세요.**
