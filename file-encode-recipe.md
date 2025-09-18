# 파일 인코딩 자동화 레시피

## 개요
Claude Code의 Write, Edit, MultiEdit 도구에서 발생하는 UTF-8 인코딩 문제를 해결하기 위해 전역 hooks 시스템을 구현했습니다.

## 문제 상황

### Claude Code 내장 도구의 인코딩 문제
- **Write 도구**: 한글과 이모지 포함 파일 생성 시 인코딩 깨짐 발생
- **Edit/MultiEdit 도구**: Windows-1252 등 다른 인코딩을 UTF-8로 강제 변환하며 특수문자 손상
- **Read 도구**: 특수문자가 포함된 파일명 처리 문제

### 실제 발생 사례
```bash
# 문제 사례: modify-git.sh 파일 생성 시
# Write 도구 사용 → charset=binary로 잘못 설정
# 한글과 이모지가 깨져서 표시됨
```

## 해결 방안

### 1. 전역 PostToolUse Hooks 구현

**설정 위치**: `.claude/settings.json`
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/scripts/illuwa/validate-utf8-encoding.sh \"$(echo '$TOOL_RESULT' | jq -r '.file_path // empty')\""
          }
        ]
      }
    ]
  }
}
```

### 2. UTF-8 인코딩 검증 스크립트

**스크립트 위치**: `.claude/scripts/illuwa/validate-utf8-encoding.sh`

**주요 기능**:
- 파일 인코딩 자동 감지 (`file -I` 명령어 사용)
- UTF-8이 아닌 경우 자동 변환 (`iconv` 사용)
- 한글/이모지 콘텐츠 표시 검증
- 변환 실패 시 원본 복구

**동작 과정**:
1. Write/Edit/MultiEdit 도구 실행 후 자동 트리거
2. 생성/수정된 파일의 인코딩 확인
3. UTF-8이 아닌 경우 백업 생성 후 변환
4. 변환 후 재검증 및 결과 출력

## 작업한 이유

### 1. 투명한 자동화
- 개발자가 의식하지 않아도 모든 파일이 UTF-8로 유지됨
- 수동 인코딩 검증 과정 불필요

### 2. 한글 개발 환경 최적화
- 한국어 주석, 메시지, 문서 안전 보장
- 이모지 사용 프로젝트에서 호환성 문제 방지

### 3. 크로스 플랫폼 호환성
- Windows, macOS, Linux 간 파일 공유 시 인코딩 문제 방지
- Git 저장소에서 일관된 인코딩 유지

### 4. CI/CD 파이프라인 안정성
- 빌드 환경에서 인코딩 관련 오류 방지
- 배포 시 문자 깨짐 현상 방지

## 기존 대안과의 비교

### Bash heredoc 방식 (기존 해결책)
```bash
cat > filename.sh << 'EOF'
#!/bin/bash
echo "한글 내용"
EOF
```
**장점**: 안전한 UTF-8 보장
**단점**: 매번 수동으로 적용해야 함

### Hooks 방식 (현재 구현)
**장점**:
- 완전 자동화
- 모든 도구에 일관 적용
- 기존 워크플로우 변경 없음

**단점**:
- 초기 설정 필요
- 시스템 환경 의존성

## 추가 고려사항

### 성능 영향
- 파일 작업 후 검증 과정으로 약간의 지연 발생
- 대용량 파일의 경우 iconv 변환 시간 소요

### 안전장치
- 변환 실패 시 원본 파일 자동 복구
- 백업 파일 생성으로 데이터 손실 방지

### 향후 개선 방향
- 특정 파일 타입별 예외 처리 추가
- 변환 성공률 모니터링 기능
- 대용량 파일 처리 최적화

## 사용법

설정 완료 후 일반적인 Claude Code 사용:
```javascript
// 이제 Write 도구 사용 시 자동으로 UTF-8 보장
Write({
  file_path: "/path/to/korean-file.sh",
  content: "#!/bin/bash\necho '한글과 이모지 📝'"
})
```

## 검증 방법

```bash
# 인코딩 확인
file -I filename.sh

# 내용 확인
cat filename.sh

# 수동 검증 스크립트 실행
bash .claude/scripts/illuwa/validate-utf8-encoding.sh filename.sh
```

이 시스템을 통해 Claude Code 사용 시 UTF-8 인코딩 문제를 완전히 해결할 수 있습니다.