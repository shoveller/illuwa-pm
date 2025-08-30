---
allowed-tools: Bash
---

프로젝트 타입을 감지하고 적절한 개발 도구를 설정합니다:

```bash
bash .claude/scripts/illuwa/setup-dev-tools.sh
```

**설정 내용:**
- TypeScript: `tsconfig.base.json` (공통) + `tsconfig.json` (프로젝트별) 분리
- ESLint: 함수형 프로그래밍 규칙 + Flat Config
- Prettier: 코드 포맷팅 
- Husky: Git Hooks (Node.js 프로젝트)
- Ruff + MyPy + pre-commit (Python 프로젝트)

**중복 설정 자동 정리:**
- 기존 `tsconfig.json`에서 `tsconfig.base.json`에 있는 중복 속성들을 자동 제거
- `extends`를 통한 상속으로 설정 최적화

**출력 옵션:**
- 전체 출력을 표시합니다
- 줄임 없이 모든 내용을 보여줍니다