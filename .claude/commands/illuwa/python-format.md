# Python Format Command

파이썬 코드의 린팅, 포매팅, 타입 검사를 한 번에 실행하는 커맨드입니다.

## 실행 방법

```bash
# 전체 포맷팅 파이프라인 실행
make format

# 또는 직접 실행
uv run ruff check --fix --unsafe-fixes && uv run ruff format && uv run mypy .
```

## 각 단계별 실행

```bash
# 1. 린팅 및 자동 수정 (import 정렬, 미사용 변수 제거 등)
uv run ruff check --fix --unsafe-fixes

# 2. 코드 포맷팅 (들여쓰기, 공백, 따옴표 등)
uv run ruff format

# 3. 타입 검사
uv run mypy .
```

## 개별 도구 사용

### Ruff 검사만

```bash
uv run ruff check .           # 검사만
uv run ruff check . --fix     # 자동 수정
```

### 포매팅만

```bash
uv run ruff format .
```

### 타입 검사만

```bash
uv run mypy .
uv run mypy . --strict  # 엄격한 검사
```

## Pre-commit 훅

커밋할 때 자동으로 실행됩니다:

```bash
git commit -m "메시지"
# 자동으로 ruff check, ruff format, mypy 실행
```

## 설정 파일

- `pyproject.toml`: Ruff 및 MyPy 설정
- `.pre-commit-config.yaml`: Pre-commit 훅 설정
- `.vscode/settings.json`: VS Code 자동 포맷팅 설정

## 자세한 가이드

`.claude/rules/illuwa/python-coding-style.md` 파일을 참조하세요.
