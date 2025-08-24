# ReadOnlyRootFilesystem 보안 강화 후 Vote 서비스 CrashLoopBackOff 문제 해결

## 📋 문제 요약

**발생 일시**: 2025-08-24  
**영향 서비스**: vote 서비스 (voting-app 네임스페이스)  
**문제 상태**: CrashLoopBackOff  
**근본 원인**: Sysdig 보안 권고사항 적용 후 임시 디렉토리 접근 불가

## 🔍 문제 분석

### 1. 초기 보안 취약점 탐지
Sysdig에서 다음과 같은 High 심각도 취약점을 탐지:

```
Remediated Control: Container with writable root file system
A container with writable root filesystem is more exposed to attacks as it allows tampering with executables

Severity: 🔴 High
Change Impact: The container will not be able to modify the root file system of the container.
Failed Requirements:
1.2 - Immutable container filesystem [Sysdig Kubernetes]
Kubernetes Controls [All Posture Findings]
```

### 2. 보안 강화 조치 적용
취약점 해결을 위해 다음 보안 설정을 적용:
```yaml
securityContext:
  readOnlyRootFilesystem: true
```

### 3. 문제 발생
보안 설정 적용 후 vote 파드가 CrashLoopBackOff 상태로 전환:

**에러 로그**:
```
FileNotFoundError: [Errno 2] No usable temporary directory found in ['/tmp', '/var/tmp', '/usr/tmp', '/usr/local/app']
```

**근본 원인**:
- `readOnlyRootFilesystem: true` 설정으로 컨테이너의 루트 파일시스템이 읽기 전용으로 변경
- gunicorn이 worker 프로세스 관리를 위해 임시 파일 생성 시도
- `/tmp`, `/var/tmp` 등 임시 디렉토리에 쓰기 권한 없음
- Python의 `tempfile.mkstemp()` 함수 실행 실패

## 🛠️ 해결 방안

### 선택된 해결책: emptyDir 볼륨 마운트
보안 설정을 유지하면서 필요한 임시 디렉토리만 쓰기 가능하도록 구성

**적용된 변경사항**:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vote
  namespace: voting-app
spec:
  template:
    spec:
      containers:
      - name: vote
        securityContext:
          readOnlyRootFilesystem: true  # 보안 설정 유지
        volumeMounts:
        - name: tmp-volume
          mountPath: /tmp
        - name: var-tmp-volume
          mountPath: /var/tmp
      volumes:
      - name: tmp-volume
        emptyDir: {}
      - name: var-tmp-volume
        emptyDir: {}
```

### 해결책의 장점
1. **보안 유지**: `readOnlyRootFilesystem: true` 설정 유지
2. **최소 권한 원칙**: 임시 디렉토리만 쓰기 가능
3. **격리**: emptyDir 볼륨으로 컨테이너별 격리된 임시 공간 제공
4. **자동 정리**: 파드 종료 시 임시 파일 자동 삭제

### 대안 검토
| 방안 | 장점 | 단점 | 선택 여부 |
|------|------|------|-----------|
| emptyDir 볼륨 | 보안 유지, 최소 권한 | 매니페스트 수정 필요 | ✅ 선택 |
| readOnlyRootFilesystem 비활성화 | 빠른 해결 | 보안 수준 저하 | ❌ 제외 |
| tmpfs 볼륨 | 성능 향상 | 메모리 사용량 증가 | ❌ 제외 |
| 애플리케이션 수정 | 근본적 해결 | 이미지 재빌드 필요 | ❌ 제외 |

## 🔒 보안 영향 평가

### 보안 강화 효과 유지
- ✅ 루트 파일시스템 읽기 전용 유지
- ✅ 실행 파일 변조 방지
- ✅ Sysdig 보안 요구사항 충족

### 추가된 보안 고려사항
- ✅ 임시 디렉토리 격리 (emptyDir)
- ✅ 파드별 독립적인 임시 공간
- ✅ 컨테이너 종료 시 자동 정리

## 📊 테스트 및 검증

### 적용 전 상태
```bash
kubectl get pods -n voting-app
# vote-d8f8447c9-xr9nm   0/1     CrashLoopBackOff   4 (22s ago)   108s
```

### 적용 후 예상 결과
```bash
kubectl get pods -n voting-app
# vote-d8f8447c9-xxxxx   1/1     Running   0   30s
```

### 검증 방법
1. 파드 상태 확인: `kubectl get pods -n voting-app`
2. 로그 확인: `kubectl logs -n voting-app deployment/vote`
3. 서비스 접근성 테스트: HTTP 요청 테스트
4. 보안 스캔 재실행: Sysdig 정책 준수 확인

## 📝 학습 사항

### 보안 강화 시 고려사항
1. **애플리케이션 요구사항 분석**: 임시 파일 사용 패턴 파악 필요
2. **단계적 적용**: 개발 환경에서 충분한 테스트 후 프로덕션 적용
3. **모니터링 강화**: 보안 설정 변경 후 애플리케이션 동작 모니터링

### 향후 개선 방안
1. **Dockerfile 최적화**: 애플리케이션 레벨에서 임시 디렉토리 설정
2. **헬스체크 강화**: 애플리케이션 시작 실패 조기 탐지
3. **문서화**: 보안 설정 변경 시 체크리스트 작성

## 🚀 배포 계획

1. **개발 환경 적용**: 현재 변경사항 적용 및 테스트
2. **검증 완료 후**: ArgoCD를 통한 자동 배포
3. **모니터링**: 배포 후 24시간 모니터링
4. **문서 업데이트**: 운영 가이드 업데이트

---

**작성자**: DevOps Team  
**검토자**: Security Team  
**승인자**: Engineering Manager  
**작성일**: 2025-08-24
