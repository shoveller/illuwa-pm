# Refinement Loop Recipe

TypeScript/TSX 파일의 함수형 프로그래밍 검증 및 자동 수정 워크플로우

## 📋 워크플로우 개요 (하이브리드 방식 ⭐)

```
파일 수정 → 개발 중
    ↓
저장 시 → Format on Save (VSCode) → 자동 수정
    ↓
계속 작업 (반복)
    ↓
커밋 준비 → /illuwa:commit (스마트 커밋)
    ↓
┌──────────────────────────────────────────────┐
│ 0. 커밋 메시지 자동 생성 (Conventional Commits) │
│    ↓                                         │
│ 1. pnpm format (빠른 자동 수정)               │
│    ↓                                         │
│ 성공? → git commit → 완료 ✅                  │
│    ↓ 실패                                    │
│ 2. 에이전트 호출 (구조 수정)                  │
│    ↓                                         │
│ 3. pnpm format (재검증)                      │
│    ↓                                         │
│ 성공? → git commit → 완료 ✅                  │
│    ↓ 실패                                    │
│ 4. 에러 리포트 → 수동 해결 안내               │
└──────────────────────────────────────────────┘
```

### 핵심 특징
- **개발 중**: Format on Save로 자동 수정, 흐름 방해 없음
- **커밋 시**: 1단계 명령어로 메시지 생성 + 검증 + 수정 + 커밋 자동화
- **Conventional Commits**: 자동으로 한글 커밋 메시지 생성
- **효율성**: 80% 케이스는 5초 내 완료
- **품질**: 모든 커밋이 함수형 프로그래밍 원칙 준수

## 🎯 설계 원칙

### 효율성 우선
- **80% 케이스**: pnpm format만으로 해결 (5초)
- **20% 케이스**: 구조적 문제 → 에이전트 호출 (60초)
- **평균 절약**: 40-50% 시간 단축

### 명확한 책임 분리

| 도구 | 담당 범위 | 처리 시간 |
|------|----------|----------|
| **pnpm format** | • 들여쓰기, 세미콜론<br>• 따옴표 통일<br>• 간단한 eslint 규칙 | ~5초 |
| **functional-typescript-enforcer** | • function → arrow<br>• 삼항 → early return<br>• let → const<br>• 중첩 if 제거 | ~30-60초 |

## 🚀 실행 방법

### 방법 1: 스마트 커밋 (완전 자동화, 가장 권장 ⭐)

```bash
# 자동 메시지 생성 (권장)
/illuwa:commit

# 수동 메시지 지정 (선택사항)
/illuwa:commit "feat(auth): 로그인 기능 추가"
```

**내부 동작:**
0. 커밋 메시지 자동 생성 (Conventional Commits 형식, 한글)
1. Git 상태 확인 및 변경된 TS/TSX 파일 식별
2. `pnpm format` 실행 (빠른 자동 수정)
3. 성공 → 즉시 `git commit` 실행 → 완료 ✅
4. 실패 → `functional-typescript-enforcer` 에이전트 자동 호출
5. 에이전트가 코드 수정 (function→arrow, let→const 등)
6. 재검증 (`pnpm format`)
7. `git add -u && git commit` 실행 → 완료 ✅

**장점:**
- **1단계 커밋**: 명령어 하나로 모든 것 자동화
- **자동 메시지**: Conventional Commits 형식 한글 메시지 자동 생성
- **자동 복구**: 대부분의 코드 품질 이슈 자동 해결
- **시간 절약**: 평균 70% 시간 단축

**사용 예시:**
```bash
# 기존 방식 (5-7단계)
# 1. 커밋 메시지 고민
git add .
git commit -m "feat(auth): 로그인 기능 구현"  # 실패
pnpm format
git add .
git commit -m "feat(auth): 로그인 기능 구현"  # 성공

# 새 방식 (1단계)
/illuwa:commit  # 메시지 자동 생성 + 모든 것이 자동!

# 또는 수동 메시지
/illuwa:commit "feat(api): 데이터 페칭 개선"
```

### 방법 2: 수동 검증 (개발 중 빠른 확인)

#### 2-1. 빠른 검증
```bash
pnpm format
```

성공하면 완료! 실패하면 2-2로 이동.

#### 2-2. 에이전트 직접 호출
```
functional-typescript-enforcer 에이전트를 호출하여
다음 파일들을 함수형 프로그래밍 원칙에 맞게 수정:
- app/lib/utils.ts
- app/root.tsx
```

### 방법 3: Format on Save (개발 중 자동화)

VSCode 설정 (이미 적용됨):

```json
// .vscode/settings.json
{
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": "explicit"
  }
}
```

**동작:**
- 파일 저장 시 → Prettier + ESLint 자동 실행
- 간단한 포맷팅 이슈 즉시 해결
- 개발 흐름 방해 없음

## 🔧 자동화 설정 (하이브리드 방식)

### 1. Quick Validate Hook (선택사항)

**파일:** `.claude/scripts/illuwa/quick-validate.sh`

```bash
#!/bin/bash
FILE="$1"

# TS/TSX 파일만 처리
if [[ ! "$FILE" =~ \.(tsx|ts)$ ]]; then
  echo '{"decision": "allow"}'
  exit 0
fi

# 빠른 검증만 (typecheck + prettier)
pnpm typecheck --noEmit && pnpm prettier --check "$FILE" 2>/dev/null

if [ $? -eq 0 ]; then
  echo '{"decision": "allow"}'
else
  echo '{"decision": "allow", "notification": "⚠️ 코드 품질 이슈: '"$FILE"'\n💡 저장 시 자동 수정, 커밋 시 /illuwa:commit 사용 권장"}'
fi
```

**Hook 설정:** `.claude/settings.json`

```json
{
  "matcher": "Edit|Write|MultiEdit",
  "hooks": [{
    "type": "command",
    "command": "bash .claude/scripts/illuwa/quick-validate.sh \"$(echo '$TOOL_RESULT' | jq -r '.file_path // empty')\""
  }]
}
```

**동작:**
- TS/TSX 파일 수정 시 → 빠른 검증 (~2초)
- 성공 → 조용히 통과
- 실패 → notification (non-blocking)

### 2. Format on Save (VSCode)

**파일:** `.vscode/settings.json` (이미 설정됨)

```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": "explicit"
  }
}
```

**동작:**
- 파일 저장 → Prettier + ESLint 자동 실행
- 간단한 이슈 즉시 해결
- 개발 흐름 방해 없음

### 3. Pre-commit Hook (Git, 선택사항)

**파일:** `.git/hooks/pre-commit`

```bash
#!/bin/bash

echo "🔍 코드 품질 검사 중..."
pnpm format

if [ $? -eq 0 ]; then
  echo "✅ 검사 통과"
  git add -u  # 수정된 파일 자동 스테이징
  exit 0
else
  echo "❌ 코드 품질 검사 실패"
  echo "💡 /illuwa:commit \"메시지\" 사용 권장 (자동 수정 포함)"
  exit 1
fi
```

**동작:**
- `git commit` 시 자동 실행
- 성공 → 수정된 파일 자동 스테이징 후 커밋
- 실패 → 커밋 차단, `/illuwa:commit` 안내

**참고:** `/illuwa:commit` 사용 시 이 hook은 우회됨 (커맨드 내부에서 검증 수행)

## 📊 성능 비교

### 시나리오별 처리 시간

| 시나리오 | 이전 순서 | 최적화 순서 | 절약 |
|---------|----------|------------|-----|
| **포맷팅만 문제**<br>(들여쓰기, 세미콜론 등) | 에이전트(45초) + format(5초)<br>= 50초 | format(5초)<br>= 5초 | **90%** ↓ |
| **함수형 위반**<br>(function, let, 중첩 if) | 에이전트(45초) + format(5초)<br>= 50초 | format 실패(5초) + 에이전트(45초) + format(5초)<br>= 55초 | 거의 동일 |
| **복합 이슈**<br>(타입 + 구조 + 포맷) | 에이전트(45초) + format 실패(5초) + 재시도(50초)<br>= 100초 | format 실패(5초) + 에이전트(45초) + format(5초)<br>= 55초 | **45%** ↓ |

**가중 평균 (포맷팅 80%, 구조 20%):**
- 이전: 50초 × 0.8 + 50초 × 0.2 = **50초**
- 최적화: 5초 × 0.8 + 55초 × 0.2 = **15초**
- **절약: 70%** 🎉

## 🎓 함수형 프로그래밍 규칙

### 자동 수정 우선순위

1. **function → const 화살표 함수**
   ```typescript
   // ❌ Before
   function getUserData() { return data; }

   // ✅ After
   const getUserData = () => data;
   ```

2. **삼항 연산자 → early return**
   ```typescript
   // ❌ Before
   const result = condition ? valueA : valueB;

   // ✅ After
   const getResult = () => {
     if (condition) return valueA;
     return valueB;
   };
   const result = getResult();
   ```

3. **let → const + 순수 함수**
   ```typescript
   // ❌ Before
   let total = 0;
   items.forEach(item => { total += item.price; });

   // ✅ After
   const total = items.reduce((sum, item) => sum + item.price, 0);
   ```

4. **else → early return 패턴**
   ```typescript
   // ❌ Before
   if (condition) {
     return valueA;
   } else {
     return valueB;
   }

   // ✅ After
   if (condition) return valueA;
   return valueB;
   ```

5. **중첩 if → early return 패턴**
   ```typescript
   // ❌ Before
   if (conditionA) {
     if (conditionB) {
       return result;
     }
   }

   // ✅ After
   if (!conditionA) return fallback;
   if (!conditionB) return fallback;
   return result;
   ```

6. **배열 변이 메서드 → 불변 메서드**
   ```typescript
   // ❌ Before
   const arr = [1, 2, 3];
   arr.push(4);

   // ✅ After
   const arr = [1, 2, 3];
   const newArr = [...arr, 4];
   ```

## 🔍 트러블슈팅

### pnpm format 실패 시

1. **타입 에러**
   ```bash
   pnpm typecheck  # 상세 타입 에러 확인
   ```

2. **Prettier 충돌**
   ```bash
   pnpm prettier  # 포맷팅만 테스트
   ```

3. **ESLint 규칙 위반**
   ```bash
   pnpm eslint  # 린트 에러만 확인
   ```

### 에이전트 호출 후에도 실패

1. **수동 코드 리뷰 필요**
   - 복잡한 비즈니스 로직
   - 외부 라이브러리 호환성
   - 타입 추론 한계

2. **임시 규칙 제외** (최후 수단)
   ```typescript
   // eslint-disable-next-line @typescript-eslint/no-explicit-any
   const data: any = complexLegacyCode();
   ```

3. **이슈 리포트 생성**
   - 에러 메시지 전체 복사
   - 관련 코드 스니펫 포함
   - 시도한 해결책 명시

## 📚 참고 자료

### 커맨드
- [/illuwa:commit](./.claude/commands/illuwa/commit.md) - 스마트 커밋 (Conventional Commits, 한글 메시지 자동 생성 + 검증 + 수정 + 커밋)

### 코딩 스타일
- [TypeScript Coding Style](./.claude/rules/illuwa/typescript-coding-style.md)
- [Project CLAUDE.md](./.claude/CLAUDE.md)

### 에이전트
- [functional-typescript-enforcer](./.claude/agents/illuwa/functional-typescript-enforcer.md) - 함수형 프로그래밍 강제 에이전트

## 🔄 워크플로우 업데이트 히스토리

- **2025-10-06 v3**: Conventional Commits 자동 생성
  - 커밋 메시지 자동 생성 기능 추가 (Level 1)
  - Conventional Commits 형식 한글 메시지
  - 커밋 메시지 입력 옵셔널화
  - Type/Scope 자동 감지 규칙

- **2025-10-06 v2**: 하이브리드 방식 구현
  - `/illuwa:commit` 스마트 커밋 커맨드 추가
  - `/illuwa:validate-ts` 제거 (간소화)
  - Quick Validate Hook 추가 (선택사항)
  - Format on Save 통합
  - Pre-commit Hook 개선 (auto-stage)
  - 1단계 커밋 워크플로우 달성

- **2025-10-06 v1**: 초기 문서 생성
  - pnpm format 우선 실행으로 변경
  - 평균 70% 성능 개선 달성
  - Hook을 block → notification으로 변경
