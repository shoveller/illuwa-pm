# 일루와 프로젝트 초기화 가이드
일루와 소프트의 개발 도구를 자동으로 설정하는 claude 커맨드 모음입니다.  
[automazeio/ccpm](https://github.com/automazeio/ccpm) 과 함께 동작하도록 설계했지만, 단독으로도 설치하고 실행할 수 있습니다.  

## 인스톨
- ccpm
```shell
curl -sSL https://raw.githubusercontent.com/shoveller/illuwa-pm/main/install/ccpm.sh | bash
```
- illuwa
```shell
curl -sSL https://raw.githubusercontent.com/shoveller/illuwa-pm/main/install/illuwa.sh | bash
```

## 저장소 클론 후에 claude 콘솔에서

1. **CCPM 초기화** (Claude Code Project Management):
   ```bash
   /pm:init
   ```

2. **일루와 개발 도구 설정** (프로젝트 타입 자동 감지):
   ```bash
   /illuwa:setup
   ```

## 설치되는 도구들

### Node.js 프로젝트 (`package.json` 감지 시)
- ESLint + Prettier 설정
- 실행: `.claude/scripts/illuwa/install-eslint.sh`와 `.claude/scripts/illuwa/install-prettier.sh`

### Python 프로젝트 (`pyproject.toml`, `requirements.txt`, `setup.py` 감지 시)
- Ruff + MyPy 설정
- 실행: `.claude/scripts/illuwa/install-ruff.sh`와 `.claude/scripts/illuwa/install-mypy.sh`

### 수동 설정 스크립트

특정 설정 스크립트를 수동으로 실행해야 하는 경우:

```bash
# Node.js 프로젝트용
bash .claude/scripts/illuwa/install-prettier.sh
bash .claude/scripts/illuwa/install-eslint.sh

# Python 프로젝트용
bash .claude/scripts/illuwa/install-ruff.sh
bash .claude/scripts/illuwa/install-mypy.sh

# 프로젝트 타입 자동 감지
bash .claude/scripts/illuwa/setup-dev-tools.sh
```

## 필요한 파일 구조

```
project-root/
├── init.md                                    # 이 파일
└── .claude/
    ├── commands/
    │   └── illuwa/
    │       └── setup.md                       # /illuwa:setup 명령 파일
    └── scripts/
        └── illuwa/
            ├── setup-dev-tools.sh             # 자동 감지 스크립트
            ├── install-prettier.sh            # Node.js 포맷팅
            ├── install-eslint.sh              # Node.js 린팅
            ├── install-ruff.sh                # Python 포맷팅/린팅
            └── install-mypy.sh                # Python 타입 체킹
```

## illuwa:setup 명령 파일 예제

`.claude/commands/illuwa/setup.md` 파일:

```markdown
---
allowed-tools: Bash
---

프로젝트 타입을 감지하고 적절한 개발 도구를 설정합니다:

```bash
bash .claude/scripts/illuwa/setup-dev-tools.sh
```

- 전체 출력을 표시합니다
- 줄임 없이 모든 내용을 보여줍니다
```

## 커스터마이징

새로운 프로젝트 타입을 추가하려면 `.claude/scripts/illuwa/setup-dev-tools.sh` 파일을 편집하고 해당 스택의 감지 로직을 추가하세요.