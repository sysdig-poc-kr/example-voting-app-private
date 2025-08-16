# Sysdig v6 보안 통합 가이드

## 개요

이 프로젝트는 example-voting-app에 Sysdig v6 보안 스캔을 통합한 완전한 DevSecOps 파이프라인입니다. 
컨테이너 이미지 취약점 스캔, Infrastructure as Code (IaC) 보안 검증, GitHub Security 탭 연동을 포함합니다.

## 🔧 구현된 보안 기능

### 1. GitHub Actions 워크플로우
- **파일**: `.github/workflows/sysdig-security-scan.yml`
- **트리거**: Push (main, develop), Pull Request (main)
- **병렬 실행**: 4개 독립적인 보안 스캔 작업

### 2. 보안 스캔 범위

#### IaC 보안 스캔
- **대상**: `k8s-specifications/` 디렉토리의 Kubernetes 매니페스트
- **검증 항목**: 보안 컨텍스트, 네트워크 정책, 리소스 제한
- **최소 심각도**: Medium 이상

#### 컨테이너 이미지 스캔
| 서비스 | 기술 스택 | 위험도 | 스캔 대상 |
|--------|-----------|--------|-----------|
| Vote | Python Flask | 중간 | OS 패키지, Python 의존성 |
| Worker | .NET Core | 낮음 | OS 패키지, .NET 의존성 |
| Result | Node.js | **높음** | OS 패키지, npm 패키지 |

### 3. SARIF 보고서 통합
- **GitHub Security 탭**: 자동 업로드 및 표시
- **Pull Request**: 보안 검사 결과 자동 표시
- **아티팩트**: 상세 스캔 결과 보관

## 🚀 설정 방법

### 1. GitHub Secrets 설정
```bash
# 필수 시크릿
SYSDIG_SECURE_API_TOKEN=your_api_token
SYSDIG_SECURE_ENDPOINT=your_endpoint_url
```

### 2. 워크플로우 활성화
1. 코드를 main 브랜치에 push
2. GitHub Actions 탭에서 실행 상태 확인
3. Security 탭에서 스캔 결과 확인

## 📊 보안 결과 확인

### GitHub Security 탭
- **Code scanning alerts**: Sysdig 스캔 결과
- **취약점별 상세 정보**: 위치, 심각도, 수정 권장사항
- **트렌드 분석**: 시간별 보안 상태 변화

### Actions 아티팩트
- **SARIF 파일**: 구조화된 분석 결과
- **JSON 파일**: 상세 스캔 데이터

## 🔍 주요 발견사항

### 높은 위험도 서비스
**Result Service (Node.js)**
- npm 패키지 취약점 다수 발견
- 정기적인 의존성 업데이트 필요
- 보안 패치 우선 적용 권장

### 보안 강화 권장사항
1. **컨테이너 보안**
   - 비특권 사용자로 실행
   - 읽기 전용 루트 파일시스템
   - 최소 권한 원칙 적용

2. **네트워크 보안**
   - 네트워크 정책 적용
   - 서비스 간 통신 암호화
   - 불필요한 포트 차단

## 🛠️ 고급 설정

### 스캔 정책 커스터마이징
```yaml
# 심각도 필터링
severity-at-least: high

# 패키지 타입 필터링
package-types: "javascript,python"
not-package-types: "os"

# 승인된 위험 제외
exclude-accepted: true
```

### 실패 조건 설정
```yaml
# 정책 평가 실패 시 빌드 중단
stop-on-failed-policy-eval: true

# 스캐너 오류 시 빌드 중단
stop-on-processing-error: true
```

## 📈 모니터링 및 알림

### 지속적 모니터링
- **주기적 스캔**: 매 커밋마다 자동 실행
- **의존성 추적**: 새로운 취약점 자동 감지
- **보안 트렌드**: 시간별 보안 상태 분석

### 알림 설정
- GitHub 알림을 통한 새로운 취약점 통지
- 심각한 취약점 발견 시 즉시 알림
- 정기적인 보안 상태 리포트

## 🎯 면접 준비 포인트

### 기술적 역량
1. **Sysdig v6 통합 경험**
2. **SARIF 표준 이해**
3. **GitHub Security 연동**
4. **컨테이너 보안 모범 사례**

### 실무 적용 사례
1. **DevSecOps 파이프라인 구축**
2. **보안 자동화 구현**
3. **취약점 관리 프로세스**
4. **보안 정책 수립 및 적용**

---

**참고**: 이 구현은 Sysdig 공식 문서를 기반으로 하며, 프로덕션 환경에서의 보안 모범 사례를 반영합니다.
