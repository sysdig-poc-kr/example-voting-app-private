# ArgoCD GitOps 배포 가이드

## 개요

이 프로젝트는 ArgoCD를 사용한 GitOps 기반 배포로 구성되었습니다. 각 마이크로서비스가 독립적으로 관리되며, GitHub Actions를 통해 자동으로 이미지 태그가 업데이트됩니다.

## 디렉토리 구조

```
├── manifests/                    # Kubernetes 매니페스트
│   ├── base/                    # 기본 리소스 (네임스페이스, 네트워크 정책)
│   ├── vote/                    # Vote 서비스
│   ├── worker/                  # Worker 서비스
│   ├── result/                  # Result 서비스
│   └── database/                # Database 서비스 (PostgreSQL, Redis)
├── argocd/                      # ArgoCD 설정
│   ├── applications/            # 개별 Application 매니페스트
│   └── voting-app.yaml         # App of Apps 패턴 메인 애플리케이션
```

## ArgoCD 애플리케이션 구조

### App of Apps 패턴
- **메인 애플리케이션**: `voting-app`
- **하위 애플리케이션들**:
  - `voting-app-base`: 네임스페이스, 네트워크 정책
  - `voting-app-vote`: Vote 서비스
  - `voting-app-worker`: Worker 서비스
  - `voting-app-result`: Result 서비스
  - `voting-app-database`: PostgreSQL, Redis

## 배포 방법

### 1. ArgoCD에 메인 애플리케이션 등록 (권장)

```bash
kubectl apply -f argocd/voting-app.yaml
```

### 2. 개별 서비스 배포 (선택사항)

각 서비스를 개별적으로 배포하려면:

```bash
kubectl apply -f argocd/applications/base-app.yaml
kubectl apply -f argocd/applications/database-app.yaml
kubectl apply -f argocd/applications/vote-app.yaml
kubectl apply -f argocd/applications/worker-app.yaml
kubectl apply -f argocd/applications/result-app.yaml
```

## GitOps 워크플로우

### 1. 코드 변경 및 빌드
1. 개발자가 서비스 코드를 변경하고 `main` 브랜치에 푸시
2. GitHub Actions가 자동으로 트리거됨:
   - Docker 이미지 빌드
   - Sysdig 보안 스캔 실행
   - Harbor Registry에 이미지 푸시
   - 매니페스트 파일의 이미지 태그 자동 업데이트

### 2. 자동 배포
1. ArgoCD가 Git 저장소 변경사항을 감지
2. 새로운 이미지 태그로 자동 동기화
3. Kubernetes 클러스터에 배포

## 보안 기능

### 컨테이너 보안
- **Sysdig 취약점 스캔**: Medium 이상 심각도 탐지
- **보안 컨텍스트**: 
  - `runAsNonRoot: true`
  - `allowPrivilegeEscalation: false`
  - `readOnlyRootFilesystem: true`
  - 모든 capabilities 제거

### 네트워크 보안
- **네트워크 정책**: 마이크로서비스 간 통신 제한
- **최소 권한 원칙**: 필요한 포트만 허용

### 인프라 보안
- **IaC 스캔**: Kubernetes 매니페스트 보안 검증
- **ArgoCD 매니페스트 스캔**: GitOps 설정 보안 검증

## 모니터링 및 관리

### ArgoCD UI 접근
```bash
# ArgoCD 서버 포트 포워딩
kubectl port-forward svc/argocd-server -n argocd 8080:443

# 브라우저에서 https://localhost:8080 접근
```

### 애플리케이션 상태 확인
```bash
# 모든 애플리케이션 상태 확인
kubectl get applications -n argocd

# 특정 애플리케이션 상세 정보
kubectl describe application voting-app -n argocd
```

### 수동 동기화
```bash
# ArgoCD CLI를 통한 수동 동기화
argocd app sync voting-app
argocd app sync voting-app-vote
```

## 트러블슈팅

### 1. 이미지 Pull 실패
Harbor Registry 인증 정보 확인:
```bash
kubectl get secret harbor-registry-secret -n voting-app -o yaml
```

### 2. 네트워크 정책 문제
네트워크 정책 상태 확인:
```bash
kubectl get networkpolicy -n voting-app
kubectl describe networkpolicy vote-network-policy -n voting-app
```

### 3. ArgoCD 동기화 실패
애플리케이션 로그 확인:
```bash
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller
```

## 롤백 방법

### Git 기반 롤백
```bash
# 이전 커밋으로 되돌리기
git revert <commit-hash>
git push origin main
```

### ArgoCD를 통한 롤백
```bash
# ArgoCD CLI를 통한 이전 버전으로 롤백
argocd app rollback voting-app-vote <revision-id>
```

## 환경별 배포

현재는 단일 환경으로 구성되어 있지만, 향후 다중 환경 지원을 위해 다음과 같이 확장 가능:

```
manifests/
├── base/           # 공통 리소스
├── overlays/       # 환경별 오버레이
│   ├── dev/
│   ├── staging/
│   └── prod/
```

## 보안 스캔 결과

- **컨테이너 이미지**: GitHub Security 탭에서 SARIF 리포트 확인
- **인프라**: GitHub Actions 아티팩트에서 IaC 스캔 결과 확인
- **Sysdig Console**: 통합 보안 분석 결과 확인

## 참고 자료

- [ArgoCD 공식 문서](https://argo-cd.readthedocs.io/)
- [Sysdig Secure 문서](https://docs.sysdig.com/en/docs/sysdig-secure/)
- [Kubernetes 네트워크 정책](https://kubernetes.io/docs/concepts/services-networking/network-policies/)

## ArgoCD 애플리케이션 구조

### App of Apps 패턴
- **메인 애플리케이션**: `voting-app`
- **하위 애플리케이션들**:
  - `voting-app-base`: 네임스페이스, 네트워크 정책
  - `voting-app-vote`: Vote 서비스
  - `voting-app-worker`: Worker 서비스
  - `voting-app-result`: Result 서비스
  - `voting-app-database`: PostgreSQL, Redis

## 배포 방법

### 1. ArgoCD에 메인 애플리케이션 등록

```bash
kubectl apply -f argocd/voting-app.yaml
```

### 2. 개별 서비스 배포 (선택사항)

각 서비스를 개별적으로 배포하려면:

```bash
kubectl apply -f argocd/applications/base-app.yaml
kubectl apply -f argocd/applications/database-app.yaml
kubectl apply -f argocd/applications/vote-app.yaml
kubectl apply -f argocd/applications/worker-app.yaml
kubectl apply -f argocd/applications/result-app.yaml
```

## GitOps 워크플로우

### 1. 코드 변경 및 빌드
1. 개발자가 서비스 코드를 변경하고 `main` 브랜치에 푸시
2. GitHub Actions가 자동으로 트리거됨:
   - Docker 이미지 빌드
   - Sysdig 보안 스캔 실행
   - Harbor Registry에 이미지 푸시
   - 매니페스트 파일의 이미지 태그 자동 업데이트

### 2. 자동 배포
1. ArgoCD가 Git 저장소 변경사항을 감지
2. 새로운 이미지 태그로 자동 동기화
3. Kubernetes 클러스터에 배포

## 보안 기능

### 컨테이너 보안
- **Sysdig 취약점 스캔**: Medium 이상 심각도 탐지
- **보안 컨텍스트**: 
  - `runAsNonRoot: true`
  - `allowPrivilegeEscalation: false`
  - `readOnlyRootFilesystem: true`
  - 모든 capabilities 제거

### 네트워크 보안
- **네트워크 정책**: 마이크로서비스 간 통신 제한
- **최소 권한 원칙**: 필요한 포트만 허용

### 인프라 보안
- **IaC 스캔**: Kubernetes 매니페스트 보안 검증
- **ArgoCD 매니페스트 스캔**: GitOps 설정 보안 검증

## 모니터링 및 관리

### ArgoCD UI 접근
```bash
# ArgoCD 서버 포트 포워딩
kubectl port-forward svc/argocd-server -n argocd 8080:443

# 브라우저에서 https://localhost:8080 접근
```

### 애플리케이션 상태 확인
```bash
# 모든 애플리케이션 상태 확인
kubectl get applications -n argocd

# 특정 애플리케이션 상세 정보
kubectl describe application voting-app -n argocd
```

### 수동 동기화
```bash
# ArgoCD CLI를 통한 수동 동기화
argocd app sync voting-app
argocd app sync voting-app-vote
```

## 트러블슈팅

### 1. 이미지 Pull 실패
Harbor Registry 인증 정보 확인:
```bash
kubectl get secret harbor-registry-secret -n voting-app -o yaml
```

### 2. 네트워크 정책 문제
네트워크 정책 상태 확인:
```bash
kubectl get networkpolicy -n voting-app
kubectl describe networkpolicy vote-network-policy -n voting-app
```

### 3. ArgoCD 동기화 실패
애플리케이션 로그 확인:
```bash
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller
```

## 롤백 방법

### Git 기반 롤백
```bash
# 이전 커밋으로 되돌리기
git revert <commit-hash>
git push origin main
```

### ArgoCD를 통한 롤백
```bash
# ArgoCD CLI를 통한 이전 버전으로 롤백
argocd app rollback voting-app-vote <revision-id>
```

## 환경별 배포

현재는 단일 환경으로 구성되어 있지만, 향후 다중 환경 지원을 위해 다음과 같이 확장 가능:

```
manifests/
├── base/           # 공통 리소스
├── overlays/       # 환경별 오버레이
│   ├── dev/
│   ├── staging/
│   └── prod/
```

## 보안 스캔 결과

- **컨테이너 이미지**: GitHub Security 탭에서 SARIF 리포트 확인
- **인프라**: GitHub Actions 아티팩트에서 IaC 스캔 결과 확인
- **Sysdig Console**: 통합 보안 분석 결과 확인

## 참고 자료

- [ArgoCD 공식 문서](https://argo-cd.readthedocs.io/)
- [Sysdig Secure 문서](https://docs.sysdig.com/en/docs/sysdig-secure/)
- [Kubernetes 네트워크 정책](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
