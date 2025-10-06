---
name: shadcn-init
description: Shadcn UI 초기 설정 (Feature 기반 구조)
---

# Shadcn UI 초기 설정

Feature 기반 디렉토리 구조에 맞게 Shadcn UI를 설정합니다.

## 사용법

```bash
/illuwa:shadcn-init
```

## 실행 단계

### 1단계: Shadcn 초기화

```bash
pnpm dlx shadcn@latest init
```

**대화형 설정:**
```
✔ Which style would you like to use? › New York
✔ Which color would you like to use as base color? › Slate
✔ Would you like to use CSS variables for colors? › yes
```

### 2단계: components.json 수정

Feature 기반 구조를 위해 컴포넌트 설치 경로를 수정합니다.  
프로젝트 루트 기준 절대경로를 사용합니다.  
`tsconfig.json` 의 `compilerOptions.paths` 를 확인해서 적절한 경로를 사용하세요.  
아래의 예는 alias 가 `~` 일 경우에 동작합니다. alias 가 `@` 인 경우가 있으니 주의하세요.  
```json
{
"compilerOptions": {
  "baseUrl": ".",
  "paths": {
    "~/*": [
      "./app/*"
    ]
  }
}
```

**자동 수정 내용:**

```json
{
  "aliases": {
    "components": "~/common/components",
    "ui": "~/common/components/ui"
  }
}
```

**Before:**
```json
{
  "$schema": "https://ui.shadcn.com/schema.json",
  "style": "new-york",
  "rsc": false,
  "tsx": true,
  "tailwind": {
    "config": "tailwind.config.ts",
    "css": "app/tailwind.css",
    "baseColor": "slate",
    "cssVariables": true
  },
  "aliases": {
    "components": "~/components",
    "ui": "~/components/ui",
    "lib": "~/lib",
    "hooks": "~/hooks"
  }
}
```

**After:**
```json
{
  "$schema": "https://ui.shadcn.com/schema.json",
  "style": "new-york",
  "rsc": false,
  "tsx": true,
  "tailwind": {
    "config": "tailwind.config.ts",
    "css": "app/tailwind.css",
    "baseColor": "slate",
    "cssVariables": true
  },
  "aliases": {
    "components": "~/common/components",
    "ui": "~/common/components/ui",
    "lib": "~/lib",
    "hooks": "~/hooks"
  }
}
```

### 3단계: 디렉토리 생성

Feature 기반 구조 디렉토리를 생성합니다.

```bash
mkdir -p app/common/components/ui
mkdir -p app/features
```

### 4단계: 최소 필수 컴포넌트 설치 (선택사항)

```bash
pnpm dlx shadcn@latest add button input card dialog
```

**설치 위치:** `app/common/components/ui/`

## 디렉토리 구조

설치 후 디렉토리 구조:

```
app/
├── common/
│   ├── components/
│   │   ├── ui/              # Shadcn 컴포넌트 (자동 생성)
│   │   │   ├── button.tsx
│   │   │   ├── input.tsx
│   │   │   ├── card.tsx
│   │   │   └── dialog.tsx
│   │   └── ...              # 공통 컴포넌트 (직접 작성)
│   └── pages/               # 공통 페이지
│
├── features/                # Feature 디렉토리 (직접 작성)
│   ├── users/
│   ├── products/
│   └── ...
│
└── lib/                     # 유틸리티
```

## Import 사용법

### Shadcn 컴포넌트 Import

```typescript
// ✅ Good: 자동 설정된 alias 사용
import { Button } from '~/common/components/ui/button'
import { Input } from '~/common/components/ui/input'
import { Card } from '~/common/components/ui/card'

// ❌ Bad: 상대 경로
import { Button } from '../../../common/components/ui/button'
```

### 사용 예시

```typescript
import { Button } from '~/common/components/ui/button'
import { Input } from '~/common/components/ui/input'
import { Card, CardHeader, CardContent } from '~/common/components/ui/card'

const LoginPage = () => {
  return (
    <Card>
      <CardHeader>
        <h2>로그인</h2>
      </CardHeader>
      <CardContent>
        <Input placeholder="이메일" />
        <Input type="password" placeholder="비밀번호" />
        <Button>로그인</Button>
      </CardContent>
    </Card>
  )
}
```

## 📦 컴포넌트 추가 방법

### 개별 컴포넌트 추가

```bash
pnpm dlx shadcn@latest add {component-name}
```

**예시:**
```bash
pnpm dlx shadcn@latest add button
pnpm dlx shadcn@latest add form
pnpm dlx shadcn@latest add table
```

### 여러 컴포넌트 한번에 추가

```bash
pnpm dlx shadcn@latest add button input card dialog form
```

## 권장 컴포넌트 목록

### 최소 필수 (4개)

| 컴포넌트 | 용도 |
|---------|------|
| **button** | 버튼, 액션 |
| **input** | 텍스트 입력 |
| **card** | 컨테이너, 레이아웃 |
| **dialog** | 모달, 다이얼로그 |

### 폼 관련 (필요시)

| 컴포넌트 | 용도 |
|---------|------|
| **form** | 폼 검증 (react-hook-form) |
| **label** | 입력 라벨 |
| **select** | 선택 입력 |
| **checkbox** | 체크박스 |
| **radio-group** | 라디오 버튼 |
| **textarea** | 여러 줄 입력 |

### UI 요소 (필요시)

| 컴포넌트 | 용도 |
|---------|------|
| **avatar** | 프로필 이미지 |
| **badge** | 태그, 라벨 |
| **alert** | 알림 메시지 |
| **dropdown-menu** | 드롭다운 메뉴 |
| **toast** | 토스트 알림 |
| **table** | 데이터 테이블 |

## 설정 확인

### components.json 검증

```bash
cat components.json
```

**확인 사항:**
- ✅ `"components": "~/common/components"`
- ✅ `"ui": "~/common/components/ui"`
- ✅ `"tsx": true`
- ✅ `"tailwind.cssVariables": true`

### 디렉토리 확인

```bash
ls -la app/common/components/ui/
```

**예상 출력:**
```
button.tsx
input.tsx
card.tsx
dialog.tsx
```

## 에러 처리

### 케이스 1: 이미 초기화됨

```
⚠️ components.json이 이미 존재합니다.
덮어쓰시겠습니까? (y/N)
```

**해결:** 수동으로 components.json 수정

### 케이스 2: pnpm 없음

```
❌ pnpm이 설치되어 있지 않습니다.
```

**해결:**
```bash
npm install -g pnpm
```

### 케이스 3: Tailwind 미설정

```
❌ Tailwind CSS가 설정되지 않았습니다.
```

**해결:** 프로젝트에 Tailwind 먼저 설치

## 완료 후 다음 단계

### 1. Feature 생성

```bash
/illuwa:feature users button input card
```

### 2. 컴포넌트 사용

```typescript
// app/features/users/pages/index.tsx
import { Button } from '~/common/components/ui/button'

const UsersPage = () => {
  return <Button>사용자 목록</Button>
}
```

### 3. 추가 컴포넌트 설치

```bash
pnpm dlx shadcn@latest add {필요한 컴포넌트}
```

## 참고 자료

### 공식 문서
- [Shadcn UI 문서](https://ui.shadcn.com/docs)
- [Shadcn with Remix](https://ui.shadcn.com/docs/installation/remix)

### 관련 파일
- [Feature 기반 구조 가이드](../../../shadcn을 활용한 feature 기반 디렉토리 구조 적용.md)
- `components.json`: Shadcn 설정 파일
- `app/common/components/ui/`: Shadcn 컴포넌트 위치

### 관련 커맨드
- `/illuwa:feature {domain}`: 새 Feature 생성
- `/illuwa:setup`: 개발 도구 초기 설정
