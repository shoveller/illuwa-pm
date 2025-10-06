---
name: commit
description: 자동 검증 + 수정 + 커밋 (Conventional Commits, 한글 메시지 자동 생성)
---

# 스마트 커밋 - 자동 검증 및 수정

TypeScript/TSX 파일을 자동으로 검증하고 수정한 후 Conventional Commits 형식으로 커밋합니다.

## 사용법

```bash
# 자동 생성 (권장 ⭐)
/illuwa:commit

# 수동 지정 (선택사항)
/illuwa:commit "feat(auth): 로그인 기능 추가"
```

**커밋 메시지 형식:** Conventional Commits
```
<type>(<scope>): <한글 메시지>
```

## 실행 단계

### 1단계: Git 상태 확인 및 커밋 메시지 생성

#### 1-1. 변경된 파일 분석

```bash
git diff --name-status
git diff --cached --name-status
```

#### 1-2. 커밋 메시지 자동 생성 (사용자 입력 없을 시)

**Type 감지 규칙:**

| 파일 패턴 | Type | 설명 |
|----------|------|-----|
| 새 파일 추가 (`A`) | `feat` | 새 기능 |
| 설정 파일 (`.claude/`, `*.config.*`, `*.json`) | `chore` | 설정 변경 |
| 문서 파일 (`*.md`) | `docs` | 문서 업데이트 |
| 테스트 파일 (`*.test.*`, `*.spec.*`) | `test` | 테스트 |
| 기존 파일 수정 + 에러 키워드 | `fix` | 버그 수정 |
| 기존 파일 수정 (일반) | `feat` | 기능 개선 |

**Scope 감지 규칙:**

| 파일 경로 | Scope | 예시 |
|----------|-------|-----|
| `app/routes/login.*`, `app/routes/auth.*` | `auth` | 인증 관련 |
| `app/routes/user.*`, `app/routes/profile.*` | `user` | 사용자 관련 |
| `app/lib/api.*` | `api` | API 관련 |
| `app/lib/utils.*` | `utils` | 유틸리티 |
| `app/components/` | `ui` | UI 컴포넌트 |
| `.claude/` | `config` | 설정 |
| 기타 | 없음 | - |

**한글 메시지 생성 규칙:**

```
- 새 파일: "<주요 기능> 추가" 또는 "<파일명> 구현"
- 파일 수정: "<주요 기능> 개선" 또는 "<기능> 수정"
- 설정 파일: "<설정명> 업데이트"
- 문서: "<문서명> 업데이트"
```

**최종 메시지 예시:**
```
feat(auth): 로그인 기능 구현
fix(api): 데이터 로딩 오류 수정
chore(config): Claude 설정 업데이트
docs: README 업데이트
```

### 2단계: 변경된 TypeScript 파일 식별

```bash
git diff --name-only --diff-filter=AM | grep '\\.tsx\?$'
```

수정되거나 추가된 TS/TSX 파일만 필터링

### 3단계: 빠른 자동 수정 시도

```bash
pnpm format
```

- `typecheck` → `prettier` → `eslint` 순서로 실행
- 80% 케이스는 여기서 해결

### 4단계: 결과 분기

#### ✅ 성공한 경우
```bash
git add -u
git commit -m "사용자가 입력한 메시지"
```

→ 커밋 해시와 성공 메시지 출력 후 종료

#### ❌ 실패한 경우
5단계로 진행

### 5단계: 에러 분석 및 에이전트 호출

`pnpm format` 에러 로그를 분석하여:

- **함수형 프로그래밍 위반** 감지 시:
  - `functional-typescript-enforcer` 에이전트 자동 호출
  - 변경된 TS/TSX 파일을 타겟팅하여 수정:
    - function → const 화살표 함수
    - 삼항 연산자 → early return
    - let → const + 순수 함수
    - else → early return 패턴
    - 중첩 if → early return 패턴
    - 배열 변이 메서드 → 불변 메서드

- **타입 에러** 또는 **기타 이슈**:
  - 상세 에러 리포트 생성
  - 사용자에게 수동 수정 안내
  - 프로세스 중단

### 6단계: 재검증

에이전트 수정 후:

```bash
pnpm format
```

### 7단계: 최종 커밋

재검증 성공 시:

```bash
git add -u
git commit -m "사용자가 입력한 메시지"
```

### 8단계: 결과 리포트

- ✅ **성공**: 커밋 해시 및 변경 파일 목록 표시
- ❌ **실패**: 상세 에러 리포트 및 수동 해결 방법 안내

## 재시도 규칙

- **최대 재시도**: 1회 (에이전트 수정 후 재검증)
- **1회 후에도 실패 시**:
  - 상세한 에러 분석 리포트 생성
  - 수동 해결 방법 제시
  - 커밋 프로세스 중단

## 에러 처리

### 케이스 1: 스테이징된 파일 없음
```
⚠️ 커밋할 변경사항이 없습니다.
git add <파일명>으로 파일을 스테이징하세요.
```

### 케이스 2: 타입 에러
```
❌ TypeScript 타입 에러 발견:
app/lib/utils.ts:15:23 - error TS2345: ...

💡 수동 수정이 필요합니다. 타입 에러를 해결한 후 다시 시도하세요.
```

### 케이스 3: 에이전트 수정 후에도 실패
```
❌ 자동 수정 후에도 검증 실패:
- 복잡한 비즈니스 로직
- 외부 라이브러리 호환성 이슈
- 타입 추론 한계

💡 수동 코드 리뷰가 필요합니다.
다음을 시도해보세요:
1. pnpm typecheck (타입 에러 상세 확인)
2. pnpm eslint (린트 에러만 확인)
3. 해당 파일 수동 검토
```

## 장점

### 개발자 경험
- **1단계 커밋**: 명령어 하나로 검증 + 수정 + 커밋
- **자동 메시지 생성**: Conventional Commits 형식 한글 메시지 자동 생성
- **자동 복구**: 대부분의 코드 품질 이슈 자동 해결
- **명확한 피드백**: 각 단계별 진행 상황 표시

### 효율성
- **80% 자동 해결**: format만으로 처리 (~5초)
- **15% 에이전트 해결**: 구조적 수정 (~60초)
- **5% 수동 개입**: 복잡한 이슈만 사용자 개입

### 품질 보증
- **커밋 전 검증**: 모든 커밋이 품질 기준 통과
- **일관된 스타일**: 자동 포맷팅으로 코드 스타일 통일
- **함수형 원칙**: 자동으로 함수형 프로그래밍 원칙 적용

## 사용 예시

### 예시 1: 자동 메시지 생성 (간단한 포맷팅)

```bash
/illuwa:commit

🔍 Git 상태 확인...
📝 변경된 파일: app/routes/login.tsx (A)
📋 자동 생성된 커밋 메시지: "feat(auth): 로그인 기능 구현"

🔧 pnpm format 실행...
✅ 검증 통과
📦 파일 스테이징...
✅ 커밋 성공: abc1234 "feat(auth): 로그인 기능 구현"
```

### 예시 2: 자동 메시지 생성 (설정 파일)

```bash
/illuwa:commit

🔍 Git 상태 확인...
📝 변경된 파일: .claude/settings.json (M)
📋 자동 생성된 커밋 메시지: "chore(config): Claude 설정 업데이트"

🔧 pnpm format 실행...
✅ 검증 통과
📦 파일 스테이징...
✅ 커밋 성공: def5678 "chore(config): Claude 설정 업데이트"
```

### 예시 3: 수동 메시지 + 함수형 위반 자동 수정

```bash
/illuwa:commit "feat(api): 데이터 페칭 로직 개선"

🔍 Git 상태 확인...
📝 변경된 TS 파일: app/lib/api.ts
🔧 pnpm format 실행...
❌ ESLint 에러 발견

🤖 functional-typescript-enforcer 에이전트 호출...
  - function → const arrow function 변환
  - let → const 변환
  - else 제거, early return 적용

🔧 재검증 중...
✅ 검증 통과
📦 파일 스테이징...
✅ 커밋 성공: ghi9012 "feat(api): 데이터 페칭 로직 개선"

📊 자동 수정 내역:
  - 2개 함수 → 화살표 함수 변환
  - 1개 let → const 변환
```

### 예시 4: 수동 개입 필요

```bash
/illuwa:commit

🔍 Git 상태 확인...
📝 변경된 파일: app/lib/validator.ts (M)
📋 자동 생성된 커밋 메시지: "feat(utils): validator 개선"

🔧 pnpm format 실행...
❌ TypeScript 타입 에러

🤖 functional-typescript-enforcer 에이전트 호출...
✅ 구조적 수정 완료

🔧 재검증 중...
❌ 타입 에러 여전히 존재:
app/lib/validator.ts:42:15 - error TS2345: Argument of type 'string' is not assignable to parameter of type 'number'.

💡 수동 수정이 필요합니다.
타입 에러를 해결한 후 /illuwa:commit을 다시 실행하세요.
```

## 기존 워크플로우 비교

### 기존 방식 (5-7단계)
```bash
1. 커밋 메시지 고민 (Conventional Commits 형식 맞추기)
2. git add .
3. git commit -m "feat(auth): 로그인 기능 구현"
4. ❌ 실패
5. pnpm format 수동 실행
6. git add .
7. git commit -m "feat(auth): 로그인 기능 구현"
```

### 새 방식 (1단계)
```bash
/illuwa:commit
# 메시지 자동 생성 + 검증 + 수정 + 커밋 모두 자동!
```

또는 수동 메시지:
```bash
/illuwa:commit "feat(api): 데이터 페칭 개선"
# 검증 + 수정 + 커밋 자동!
```

## 참고

- 이 커맨드는 pre-commit hook을 우회합니다
- 커밋 전 자동으로 품질 검증을 수행하므로 hook 불필요
- 긴급 상황에서는 기존 `git commit` 사용 가능 (hook이 실행됨)

## 관련 커맨드

- `pnpm format`: 빠른 포맷팅만 수행 (검증 전용)
