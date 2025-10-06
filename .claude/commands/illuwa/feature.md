---
name: feature
description: Feature 기반 구조 생성 + Shadcn 추가 + 자동 커밋
---

# Feature 생성 및 관리

Feature 기반 디렉토리 구조로 새로운 도메인을 생성하고 자동으로 커밋합니다.

## 사용법

```bash
# Feature만 생성
/illuwa:feature users

# Feature + Shadcn 컴포넌트
/illuwa:feature users button input card

# 복수 컴포넌트
/illuwa:feature products button input dialog table
```

## 📋 디렉토리 구조 규칙

### 기본 구조
```
app/
├── common/              # 공통 요소
│   ├── components/      # 공유 컴포넌트
│   │   ├── ui/         # Shadcn 컴포넌트
│   │   └── ...         # 공통 컴포넌트
│   └── pages/          # 공통 페이지
│
└── features/           # 도메인별 기능
    ├── users/          # 사용자 도메인
    │   ├── pages/      # 유저 페이지
    │   ├── components/ # 유저 전용 컴포넌트
    │   └── types/      # 유저 타입
    │
    ├── products/       # 상품 도메인
    └── ...
```

### Import 규칙

```typescript
// ✅ Good: 절대 경로 사용
import { Button } from '~/common/components/ui/button'
import { UserAvatar } from '~/features/users/components/avatar'

// ❌ Bad: 상대 경로
import { Button } from '../../../common/components/ui/button'

// ❌ Bad: Feature 간 직접 참조
import { ProductCard } from '~/features/products/components/card'
```

### 금지 사항

- ❌ 중첩 features: `features/users/features/` 금지
- ❌ 순환 참조: Feature 간 직접 import 금지
- ❌ 공통 요소를 feature에 배치
- ❌ 단수형 이름: `user` (X) → `users` (O)

## 실행 단계

### 1단계: Feature 디렉토리 생성

```bash
mkdir -p app/features/{domain}/pages
mkdir -p app/features/{domain}/components
mkdir -p app/features/{domain}/types
```

**생성되는 구조:**
```
app/features/{domain}/
├── pages/
│   └── index.tsx      # 기본 페이지
├── components/
│   └── .gitkeep       # 디렉토리 유지
└── types/
    └── index.ts       # 타입 정의
```

### 2단계: 템플릿 파일 생성

**pages/index.tsx:**
```typescript
import type { Route } from './+types/index'

export const meta = ({ data }: Route.MetaArgs) => {
  return [{ title: '{Domain}' }]
}

export const loader = async ({ params }: Route.LoaderArgs) => {
  return { message: 'Hello from {domain}!' }
}

const {Domain}Page = ({ loaderData }: Route.ComponentProps) => {
  return (
    <div>
      <h1>{domain} Page</h1>
      <p>{loaderData.message}</p>
    </div>
  )
}

export default {Domain}Page
```

**types/index.ts:**
```typescript
// {Domain} 관련 타입 정의
export type {Domain}Item = {
  id: string
  name: string
}
```

### 3단계: Shadcn 컴포넌트 추가 (지정된 경우)

```bash
pnpm dlx shadcn@latest add {components}
```

**설치 위치:** `app/common/components/ui/`

**최소 권장 컴포넌트:**
- button, input, card, dialog

### 4단계: Route 등록 안내

```typescript
// app/routes.ts에 추가 필요
import { type RouteConfig, route } from '@react-router/dev/routes'

export default [
  // 기존 라우트...
  route('/{domain}', 'features/{domain}/pages/index.tsx'),
] satisfies RouteConfig
```

### 5단계: 자동 검증 및 커밋

#### 5-1. 코드 검증
```bash
pnpm format
```

- `typecheck` → `prettier` → `eslint` 순서 실행
- 80% 케이스는 여기서 해결

#### 5-2. 실패 시 자동 수정

`functional-typescript-enforcer` 에이전트 호출:
- function → const 화살표 함수
- let → const + 순수 함수
- else → early return 패턴
- 배열 변이 → 불변 메서드

#### 5-3. 재검증
```bash
pnpm format
```

#### 5-4. 커밋 메시지 생성

**형식:** Conventional Commits
```
feat(features): {domain} feature 추가
```

**Shadcn 컴포넌트 포함 시:**
```
feat(features): {domain} feature 추가 (button, input 포함)
```

**예시:**
```
feat(features): users feature 추가
feat(features): products feature 추가 (button, card, dialog 포함)
```

#### 5-5. 최종 커밋
```bash
git add -u
git commit -m "feat(features): {domain} feature 추가"
```

### 6단계: 결과 리포트

```
✅ Feature 생성 완료: users
📁 생성된 디렉토리:
  - app/features/users/pages/
  - app/features/users/components/
  - app/features/users/types/

📦 Shadcn 컴포넌트 추가:
  ✅ button
  ✅ input

🔧 코드 검증:
  ✅ pnpm format 통과

📋 커밋 메시지: "feat(features): users feature 추가 (button, input 포함)"
✅ 커밋 성공: abc1234

📝 다음 단계:
1. app/routes.ts에 라우트 추가
2. app/features/users/pages/index.tsx 구현 시작
```

## 📦 Shadcn 컴포넌트 전략

### 최소 필수 (권장 ⭐)

| 컴포넌트 | 용도 | 우선순위 |
|---------|------|---------|
| **button** | 버튼, 액션 | 🔴 필수 |
| **input** | 폼 입력 | 🔴 필수 |
| **card** | 레이아웃 | 🟡 권장 |
| **dialog** | 모달, 다이얼로그 | 🟡 권장 |

### 필요시 추가

| 컴포넌트 | 시기 | 예시 |
|---------|------|-----|
| **form** | 폼 검증 필요 시 | 회원가입 |
| **table** | 데이터 테이블 | 사용자 목록 |
| **dropdown-menu** | 드롭다운 | 네비게이션 |
| **avatar** | 프로필 이미지 | 사용자 아바타 |
| **select** | 선택 입력 | 카테고리 선택 |
| **checkbox** | 체크박스 | 동의 항목 |

### 컴포넌트 최소화 팁

#### 1. Props로 변형 활용
```typescript
// ❌ Bad: 여러 버튼 컴포넌트
<PrimaryButton />
<SecondaryButton />
<DangerButton />

// ✅ Good: 하나의 Button + variant
<Button variant="default" />
<Button variant="secondary" />
<Button variant="destructive" />
```

#### 2. Composition 활용
```typescript
// ❌ Bad: 특화된 카드 컴포넌트
<UserCard user={user} />
<ProductCard product={product} />

// ✅ Good: 기본 Card + 조합
<Card>
  <CardHeader>
    <UserAvatar user={user} />
  </CardHeader>
  <CardContent>...</CardContent>
</Card>
```

#### 3. 늦은 최적화
```typescript
// 처음: 간단하게
<div className="custom-component">...</div>

// 반복될 때: Shadcn 추가
/illuwa:feature shadcn {component}
```

## 에러 처리

### 케이스 1: 이미 존재하는 Feature
```
⚠️ Feature가 이미 존재합니다: app/features/users/
덮어쓰시겠습니까? (y/N)
```

### 케이스 2: 검증 실패
```
❌ TypeScript 타입 에러:
app/features/users/pages/index.tsx:15:23 - error TS2345: ...

🤖 functional-typescript-enforcer 자동 수정 중...
✅ 수정 완료

🔧 재검증 중...
✅ 검증 통과
```

### 케이스 3: 커밋 실패
```
❌ 커밋할 변경사항이 없습니다.
모든 파일이 이미 최신 상태입니다.
```

### 케이스 4: Shadcn 컴포넌트 설치 실패
```
❌ Shadcn 컴포넌트 설치 실패: button
원인: 인터넷 연결 오류

💡 수동으로 설치하세요:
   pnpm dlx shadcn@latest add button
```

## 사용 예시

### 예시 1: 기본 Feature 생성

```bash
/illuwa:feature users

# 출력:
✅ Feature 생성 완료: users
📁 app/features/users/ (pages, components, types)
🔧 코드 검증 통과
📋 커밋: "feat(features): users feature 추가"
✅ 커밋 성공: abc1234
```

### 예시 2: Shadcn 컴포넌트 포함

```bash
/illuwa:feature products button input card dialog

# 출력:
✅ Feature 생성 완료: products
📦 Shadcn 컴포넌트:
  ✅ button
  ✅ input
  ✅ card
  ✅ dialog
🔧 코드 검증 통과
📋 커밋: "feat(features): products feature 추가 (button, input, card, dialog 포함)"
✅ 커밋 성공: def5678
```

### 예시 3: 검증 실패 후 자동 수정

```bash
/illuwa:feature jobs button

# 출력:
✅ Feature 생성 완료: jobs
📦 Shadcn: button
🔧 코드 검증 중...
❌ ESLint 에러 발견

🤖 functional-typescript-enforcer 자동 수정:
  - 2개 함수 → 화살표 함수 변환
  - 1개 let → const 변환

🔧 재검증 중...
✅ 검증 통과
📋 커밋: "feat(features): jobs feature 추가 (button 포함)"
✅ 커밋 성공: ghi9012
```

## ✅ 체크리스트

### Feature 생성 전
- [ ] 도메인 이름은 복수형 (users, products, jobs)
- [ ] 기존 Feature와 중복 확인
- [ ] 필요한 Shadcn 컴포넌트 파악

### Feature 생성 후
- [ ] app/routes.ts에 라우트 등록
- [ ] pages/index.tsx 구현
- [ ] 필요시 추가 컴포넌트 작성

### 커밋 전 확인
- [ ] 타입 에러 없음
- [ ] 린트 에러 없음
- [ ] 함수형 프로그래밍 원칙 준수

### 구현 시 주의사항
- [ ] 절대 경로 import 사용
- [ ] Feature 간 직접 참조 금지
- [ ] 공통 컴포넌트는 app/common/에 배치

## 참고 자료

### 관련 문서
- [Shadcn 공식 문서](https://ui.shadcn.com/docs)
- [Feature 기반 구조 가이드](../../../shadcn을 활용한 feature 기반 디렉토리 구조 적용.md)

### 관련 커맨드
- `/illuwa:commit`: 수동 커밋 (자동 메시지 생성)
- `pnpm format`: 코드 검증 및 포맷팅

### 코딩 스타일
- [TypeScript Coding Style](../../rules/illuwa/typescript-coding-style.md)
- [functional-typescript-enforcer](../../agents/illuwa/functional-typescript-enforcer.md)
