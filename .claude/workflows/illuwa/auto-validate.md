---
name: auto-validate
description: 파일 변경 시 자동 검증 및 피드백 루프 실행
---

# 자동 검증 워크플로우

## 트리거 조건
- `*.tsx`, `*.ts` 파일 변경 감지 시
- Diagnostic 오류 (ESLint, TypeScript, React Hooks) 감지 시
- 파일 저장 후 자동 실행

## 검증 프로세스

### 1단계: 함수형 코드 검증
- functional-typescript-enforcer 에이전트 실행
- TypeScript 함수형 프로그래밍 원칙 준수 확인
- 위반 사항 자동 수정

### 2단계: 품질 검증
- `pnpm format` 실행 (typecheck → prettier → eslint)
- 모든 품질 기준 통과 확인

### 3단계: 피드백 루프
- 검증 실패 시 → 수정 → 재검증
- 최대 반복 횟수: 2회
- 2회 후에도 실패 시 사용자에게 보고

## 실행 흐름
```
파일 변경
  ↓
트리거 조건 확인
  ↓
functional-typescript-enforcer 실행
  ↓
수정 사항 적용
  ↓
pnpm format 실행
  ↓
성공? → 완료
  ↓
실패? → 재시도 (최대 2회)
  ↓
최종 실패 → 사용자 보고
```

## 자동 수정 범위

### ✅ 자동 수정 가능:
- `function` → `const 화살표 함수`
- 삼항 연산자 → early return
- `let` → `const` + 순수 함수
- `else` → early return 패턴
- 중첩 if → early return 패턴
- 배열 변이 메서드 → 불변 메서드

### ⚠️ 사용자 확인 필요:
- 복잡한 로직 구조 변경
- 타입 오류 해결
- 의존성 관련 문제
- React hooks 규칙 위반 (컴포넌트 구조 변경)

## 성공 기준
- ✅ functional-typescript-enforcer 검증 통과
- ✅ TypeScript 타입 체크 통과
- ✅ ESLint 규칙 통과
- ✅ Prettier 포맷팅 통과

## 실행 예시

### 자동 트리거 시나리오
```
# 상황: button.tsx 파일 수정 후 저장
1. 파일 변경 감지: app/components/ui/button.tsx
2. 트리거 조건 충족: *.tsx 파일
3. functional-typescript-enforcer 실행
4. 검증 결과:
   - function → const 화살표 함수 변환
   - 삼항 연산자 → early return 변환
5. 수정 사항 자동 적용
6. pnpm format 실행
7. 모든 검증 통과 ✅
```

### 피드백 루프 시나리오
```
# 상황: 복잡한 로직 수정 후 ESLint 오류 발생
1. functional-typescript-enforcer 실행
2. 첫 번째 수정 시도
3. pnpm format 실행 → ESLint 오류 발견
4. 두 번째 수정 시도 (재검증 1회차)
5. pnpm format 실행 → 통과 ✅
```

## 에이전트 실행 규칙

### functional-typescript-enforcer
**트리거**:
- TypeScript/JavaScript 파일 변경
- Diagnostic에서 함수형 프로그래밍 위반 감지

**작업**:
1. 코드 분석 및 위반 사항 식별
2. 함수형 원칙에 따라 코드 자동 리팩토링
3. Edit 도구로 파일 직접 수정
4. 변경 내용 및 이유 보고

### 피드백 루프 제어
```typescript
const MAX_RETRIES = 2
let retryCount = 0

while (retryCount < MAX_RETRIES) {
  // 1. 검증 실행
  const validationResult = await runValidation()

  if (validationResult.success) {
    break // 성공 시 루프 종료
  }

  // 2. 자동 수정 시도
  await applyAutoFix()

  retryCount++
}

if (retryCount === MAX_RETRIES && !success) {
  reportToUser("자동 수정 실패: 사용자 확인 필요")
}
```

## 설정

### 비활성화 방법
워크플로우를 비활성화하려면 이 파일 상단의 frontmatter에 추가:
```yaml
---
name: auto-validate
description: 파일 변경 시 자동 검증 및 피드백 루프 실행
enabled: false  # 추가
---
```

### 커스터마이징
최대 재시도 횟수 변경:
```markdown
### 3단계: 피드백 루프
- 최대 반복 횟수: 3회  # 2회에서 3회로 변경
```

## 주의사항
1. **성능**: 대규모 파일 변경 시 검증에 시간이 소요될 수 있음
2. **충돌 방지**: 수동 편집 중에는 자동 검증 일시 중단 권장
3. **Git 충돌**: 자동 수정 전 항상 git status 확인
4. **백업**: 중요한 변경 전 커밋 권장
