# Python Coding Style Guide

> 파이썬 코드를 유지보수 가능한 수준으로 관리하기 위한 린터, 포매터, 타입 체커 설정 가이드

## 개요

이 프로젝트는 다음 도구들을 사용하여 파이썬 코드 품질을 관리합니다:

- **Ruff**: 고성능 파이썬 린터 및 포매터 (JavaScript의 Biome과 유사)
- **MyPy**: 정적 타입 검사기 (TypeScript의 tsc와 유사)
- **pre-commit**: Git 커밋 전 자동 검사 도구

## Ruff 설정

### 목표
- 코드 스타일 자동 통일
- 일반적인 버그 패턴 감지
- Import 문 자동 정렬

### 주요 설정

```toml
[tool.ruff]
target-version = "py312"          # Python 3.12 대상
line-length = 88                  # 한 줄 최대 길이
indent-width = 4                  # 들여쓰기 (4칸 표준)

[tool.ruff.format]
quote-style = 'single'            # 단일 따옴표 사용
line-ending = 'lf'                # Unix 줄바꿈

[tool.ruff.lint]
select = [
    'E',   # PEP 8 스타일 (들여쓰기, 공백)
    'W',   # 스타일 경고
    'F',   # Pyflakes (논리 오류, 미사용 변수)
    'I',   # import 정렬 및 그룹화
    'UP',  # 레거시 문법을 현대 Python으로 업그레이드
    'B',   # flake8-bugbear (흔한 버그 패턴)
    'RUF', # Ruff 전용 규칙
]
ignore = [
    'E501',  # 줄 길이 (자동 포맷팅으로 처리)
    'D',     # docstring (선택적)
    'ANN',   # 타입 어노테이션 (mypy 담당)
]
```

### 실행 방법

```bash
# 검사만 실행
ruff check .

# 자동으로 수정하기
ruff check . --fix

# 코드 포맷팅
ruff format .

# 파일 변경 감시
ruff check . --watch
```

## MyPy 설정

### 목표
- 타입 안전성 확보
- 런타임 오류 사전 방지
- 점진적 타입 도입 지원

### 주요 설정

```toml
[tool.mypy]
python_version = '3.12'
explicit_package_bases = true
warn_return_any = true
warn_unused_configs = true
allow_redefinition = false

# 관대한 설정 (점진적 타입 도입)
disallow_untyped_defs = false
disallow_untyped_calls = false
disallow_any_expr = false
ignore_missing_imports = true
check_untyped_defs = false
warn_unused_ignores = false
disallow_incomplete_defs = false
```

### 모듈별 예외

```toml
# 테스트 파일
[[tool.mypy.overrides]]
module = "tests.*"
ignore_errors = true

# 외부 패키지 (타입 정보 없음)
[[tool.mypy.overrides]]
module = ['setuptools.*', 'distutils.*']
ignore_missing_imports = true

# LangChain (타입 정의 불완전)
[[tool.mypy.overrides]]
module = ['langchain_core.*', 'langchain_openai.*']
ignore_errors = true
```

### 실행 방법

```bash
# 전체 프로젝트 타입 검사
mypy .

# 특정 디렉토리만 검사
mypy src/

# 엄격한 검사
mypy --strict .

# 누락된 타입 스텁 자동 설치
mypy --install-types
```

## Pre-commit 설정

### 목표
- 커밋 전 자동으로 코드 검사
- 문제가 있으면 커밋 방지

### 설정 순서

1. **ruff check --fix**: 자동으로 수정 가능한 린트 오류 해결
2. **ruff format**: 정렬 후 포맷팅 적용
3. **mypy**: 타입 검사 수행

```yaml
repos:
  - repo: local
    hooks:
      - id: ruff-check
        name: ruff check
        entry: uv run ruff check --fix --unsafe-fixes
        language: system
        types: [python]
        pass_filenames: false
        always_run: true

      - id: ruff-format
        name: ruff format
        entry: uv run ruff format
        language: system
        types: [python]
        pass_filenames: false
        always_run: true

      - id: mypy
        name: mypy
        entry: uv run mypy .
        language: system
        types: [python]
        pass_filenames: false
        always_run: true
```

### 설치

```bash
# pre-commit 설치
uv add pre-commit --dev

# Git hooks 등록
uv run pre-commit install

# 모든 파일에 대해 수동 실행
uv run pre-commit run --all-files
```

## 코딩 스타일 규칙

### Import 정렬

```python
# 표준 라이브러리
import os
import sys

# 서드파티 라이브러리
from typing import Any
from langchain_core import BaseLanguageModel

# 로컬 모듈
from .utils import helper_function
```

### 문자열 스타일

```python
# 단일 따옴표 사용
name = 'John'
message = 'Hello, world!'

# 특수 문자가 포함된 경우
text = 'It\'s a beautiful day'
```

### 줄 길이

- 최대 88자 (PEP 8 권장 79자보다 현대적)
- 필요시 자동으로 줄바꿈됨

### 타입 어노테이션

```python
# 권장: 함수 시그니처에 타입 지정
def greet(name: str) -> str:
    return f'Hello, {name}!'

# 복잡한 경우 부분적으로 생략 가능
def process_data(config):  # 초기 개발 단계
    pass
```

### Docstring

선택적이지만 권장:

```python
def calculate_total(items: list[int]) -> int:
    """아이템 목록의 합계를 계산합니다.

    Args:
        items: 정수 목록

    Returns:
        합계 값
    """
    return sum(items)
```

## 전체 포맷팅 파이프라인

### Makefile 사용

```bash
make format      # 전체 파이프라인 실행 (lint -> format -> type-check)
make lint        # 린팅만
make style       # 포매팅만
make type-check  # 타입 검사만
```

### 수동 실행

```bash
# 1단계: 린트 검사 및 자동 수정
uv run ruff check --fix --unsafe-fixes

# 2단계: 코드 포맷팅
uv run ruff format

# 3단계: 타입 검사
uv run mypy .
```

## IDE 통합

### VS Code

#### Ruff

1. 확장 프로그램 설치: [Ruff](https://marketplace.visualstudio.com/items?itemName=charliermarsh.ruff)
2. 설정 (.vscode/settings.json):

```json
{
  "[python]": {
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
      "source.fixAll.ruff": true,
      "source.organizeImports.ruff": true
    },
    "editor.defaultFormatter": "charliermarsh.ruff"
  },
  "ruff.lint.args": ["--config=pyproject.toml"]
}
```

#### MyPy

1. 확장 프로그램 설치: [MyPy](https://marketplace.visualstudio.com/items?itemName=ms-python.mypy-type-checker)
2. 설정 (.vscode/settings.json):

```json
{
  "python.linting.enabled": true,
  "python.linting.mypyEnabled": true,
  "python.linting.mypyArgs": [
    "--strict",
    "--show-error-codes"
  ],
  "python.analysis.typeCheckingMode": "strict"
}
```

### IntelliJ / PyCharm

- [Ruff 플러그인](https://plugins.jetbrains.com/plugin/20574-ruff) 설치
- [MyPy 플러그인](https://plugins.jetbrains.com/plugin/25888-mypy) 설치

## 트러블슈팅

### "mypy 찾을 수 없음" 오류

```bash
# mypy 설치
uv add mypy --dev

# 또는 시스템 전역 설치
pip install mypy
```

### Pre-commit 훅 실패

```bash
# 모든 파일에 대해 수동으로 실행해서 확인
uv run pre-commit run --all-files

# 개별 훅 실행
uv run ruff check . --fix
uv run ruff format .
uv run mypy .
```

### import 순서 오류

```bash
# Ruff의 isort 규칙으로 자동 정렬
uv run ruff check --fix .
```

## 참고 자료

- [Ruff Documentation](https://docs.astral.sh/ruff/)
- [MyPy Documentation](https://mypy.readthedocs.io/)
- [PEP 8 Style Guide](https://pep8.org/)
- [Pre-commit Documentation](https://pre-commit.com/)
