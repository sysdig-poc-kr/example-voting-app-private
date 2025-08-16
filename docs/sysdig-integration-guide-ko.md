# Sysdig v6 보안 통합 가이드

## 개요

이 프로젝트는 example-voting-app에 Sysdig v6 보안 스캔을 통합한 완전한 DevSecOps 파이프라인입니다. 
Amazon EKS 배포를 위한 컨테이너 이미지 취약점 스캔, Infrastructure as Code (IaC) 보안 검증, GitHub Security 탭 연동을 포함합니다.

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
- **결과 위치**: **Sysdig Secure Console 전용**

#### 컨테이너 이미지 스캔
| 서비스 | 기술 스택 | 위험도 | 스캔 대상 | GitHub Security 연동 |
|--------|-----------|--------|-----------|---------------------|
| Vote | Python Flask | 중간 | OS 패키지, Python 의존성 | ✅ SARIF 업로드 |
| Worker | .NET Core | 낮음 | OS 패키지, .NET 의존성 | ✅ SARIF 업로드 |
| Result | Node.js | **높음** | OS 패키지, npm 패키지 | ✅ SARIF 업로드 |

### 3. 이중 보고 시스템
- **GitHub Security 탭**: 컨테이너 이미지 취약점 (SARIF 형식)
- **Sysdig Secure Console**: 종합 보안 분석 및 IaC 정책 검증
- **GitHub Artifacts**: 상세 스캔 결과 보관 (컨테이너 스캔만)

## 🚀 EKS 배포 중심 설정

### 1. GitHub Secrets 설정
```bash
# 필수 시크릿
SYSDIG_SECURE_API_TOKEN=your_api_token
SYSDIG_SECURE_ENDPOINT=your_endpoint_url
```

### 2. EKS 클러스터 준비
```bash
# EKS 클러스터 생성 (예시)
eksctl create cluster \
  --name voting-app-cluster \
  --region us-west-2 \
  --nodegroup-name standard-workers \
  --node-type t3.medium \
  --nodes 3 \
  --nodes-min 1 \
  --nodes-max 4
```

### 3. 워크플로우 활성화
1. 코드를 main 브랜치에 push
2. GitHub Actions 탭에서 실행 상태 확인
3. Security 탭에서 컨테이너 스캔 결과 확인
4. Sysdig Console에서 IaC 스캔 결과 확인

## 📊 보안 결과 분석

### GitHub Security 탭에서 확인 가능한 내용
- **컨테이너 이미지 취약점**: CVE 정보, 심각도, 영향받는 패키지
- **수정 권장사항**: 패키지 업데이트 가이드
- **트렌드 분석**: 시간별 보안 상태 변화
- **Pull Request 통합**: 새로운 취약점 자동 감지

### Sysdig Secure Console에서 확인 가능한 내용
- **IaC 정책 준수**: Kubernetes 보안 설정 검증
- **런타임 보안**: 실시간 위협 탐지
- **컴플라이언스**: 보안 표준 준수 상태
- **종합 대시보드**: 전체 보안 포스처 분석

## 🔍 주요 발견사항 및 권장사항

### 높은 위험도 서비스: Result Service (Node.js)
**문제점:**
- npm 패키지 취약점 다수 발견
- JavaScript 의존성 관리 복잡성

**권장 조치:**
```bash
# 정기적인 의존성 업데이트
npm audit fix

# 보안 패키지 스캔
npm audit --audit-level moderate
```

### EKS 보안 강화 권장사항
1. **Pod 보안 표준**
   ```yaml
   securityContext:
     runAsNonRoot: true
     runAsUser: 1000
     readOnlyRootFilesystem: true
   ```

2. **네트워크 정책**
   ```yaml
   apiVersion: networking.k8s.io/v1
   kind: NetworkPolicy
   metadata:
     name: deny-all-ingress
   spec:
     podSelector: {}
     policyTypes:
     - Ingress
   ```

3. **리소스 제한**
   ```yaml
   resources:
     limits:
       cpu: 500m
       memory: 512Mi
     requests:
       cpu: 250m
       memory: 256Mi
   ```

## 🛠️ 고급 설정

### 스캔 정책 커스터마이징
```yaml
# 심각도 필터링
severity-at-least: high

# 패키지 타입 필터링 (컨테이너 스캔)
package-types: "javascript,python"
not-package-types: "os"

# IaC 스캔 설정
minimum-severity: medium
recursive: true
```

### 실패 조건 설정
```yaml
# 정책 평가 실패 시 빌드 중단 (프로덕션 환경)
stop-on-failed-policy-eval: true

# 스캐너 오류 시 빌드 중단
stop-on-processing-error: true
```

## 📈 모니터링 및 운영

### 지속적 보안 모니터링
- **자동 스캔**: 매 커밋마다 보안 검사 실행
- **의존성 추적**: 새로운 취약점 자동 감지
- **정책 준수**: EKS 보안 설정 지속적 검증

### EKS 운영 보안
```bash
# 클러스터 보안 상태 확인
kubectl get pods --all-namespaces -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.securityContext}{"\n"}{end}'

# 네트워크 정책 확인
kubectl get networkpolicies --all-namespaces

# 리소스 사용량 모니터링
kubectl top pods --all-namespaces
```

## 🎯 면접 준비 포인트

### 기술적 역량 시연
1. **Sysdig v6 통합 경험**
   - 컨테이너 이미지 스캔 vs IaC 스캔 차이점 설명
   - SARIF 표준 이해 및 GitHub Security 연동

2. **EKS 보안 모범 사례**
   - Pod Security Standards 적용
   - Network Policies 구현
   - RBAC 설정

3. **DevSecOps 파이프라인**
   - Shift-left 보안 접근법
   - 자동화된 보안 검증
   - 지속적 컴플라이언스

### 실무 적용 사례
1. **마이크로서비스 보안**
   - 서비스별 위험도 평가
   - 의존성 관리 전략
   - 런타임 보안 모니터링

2. **클라우드 네이티브 보안**
   - EKS 클러스터 보안 설정
   - AWS 보안 서비스 통합
   - 컨테이너 이미지 보안

3. **보안 자동화**
   - CI/CD 파이프라인 보안 통합
   - 정책 기반 보안 검증
   - 자동화된 취약점 관리

## 🔧 문제 해결

### 일반적인 문제
1. **IaC 스캔에서 SARIF 파일이 생성되지 않음**
   - **정상 동작**: IaC 스캔은 SARIF를 생성하지 않음
   - **해결책**: Sysdig Console에서 결과 확인

2. **컨테이너 스캔 실패**
   - Docker 이미지 빌드 확인
   - Sysdig API 토큰 및 엔드포인트 검증

3. **GitHub Security 탭에 결과가 표시되지 않음**
   - SARIF 파일 업로드 상태 확인
   - 권한 설정 검토

---

**참고**: 이 구현은 Sysdig 공식 문서를 기반으로 하며, Amazon EKS 프로덕션 환경에서의 보안 모범 사례를 반영합니다.
