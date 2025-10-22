#python #ruff #linter #formatter #pre-commit

- 파이썬 코드를 유지보수 가능한 수준으로 관리하기 위한 린터와 포매터가 설정 스크립트.

# ruff
- 파이썬 생태계에는 [ruff](https://github.com/astral-sh/ruff) 라는 것이 있는데, 포매팅과 린팅을 동시에 실행한다.
	- 자바스크립트 생태계의 biome 와 유사하다.
## 설치
- [uv](https://github.com/astral-sh/uv) 기반 프로젝트에서 작업한다고 가정한다
```sh
uv add ruff --dev
```

- `pyproject.toml` 에 룰을 추가한다.
	- [[메타 프레임워크의 eslint 설정 정리(2025년 8월 4일)]] , [[메타 프레임워크의 prettier 설정 정리(2025년 8월 4일)]] 설정을 참고해서 생성했다.
```toml
# ===================================================================
# Ruff 설정 - 고성능 Python 린터 및 포매터
# ===================================================================
[tool.ruff]
# Python 버전 대상 설정 - 최신 문법 기능 활용 및 체크 기준
target-version = "py312"
# 한 줄 최대 길이 - 가독성과 유지보수성 균형점 (PEP 8 권장: 79, 현대적: 88-100)
line-length = 88
# 들여쓰기 칸수 - 일관된 코드 스타일 (2칸: 간결, 4칸: 표준)
indent-width = 4

# ===================================================================
# 코드 포매팅 규칙 - 자동 스타일 통일
# ===================================================================
[tool.ruff.format]
# 문자열 따옴표 스타일 - 팀 전체 일관성 (single: 타이핑 편의, double: JSON 호환)
quote-style = 'single'
# 줄바꿈 문자 통일 - OS 간 호환성 보장 (LF: Unix/Linux, CRLF: Windows)
line-ending = 'lf'

# ===================================================================
# 린팅 규칙 설정 - 코드 품질 및 버그 예방
# ===================================================================
[tool.ruff.lint]
# 활성화할 검사 규칙들 - 엄선된 품질 향상 규칙들
select = [
    'E',   # pycodestyle 에러 - PEP 8 스타일 가이드 준수 (들여쓰기, 공백)
    'W',   # pycodestyle 경고 - 스타일 문제 (불필요한 공백, 빈 줄)
    'F',   # Pyflakes - 논리적 오류 (미사용 변수/import, 정의되지 않은 이름)
    'I',   # isort - import 문 정렬 및 그룹화 (표준/서드파티/로컬 분리)
    'UP',  # pyupgrade - 레거시 문법을 현대 Python으로 업그레이드
    'B',   # flake8-bugbear - 흔한 버그 패턴 감지 (무한루프, 잘못된 비교)
    'RUF', # Ruff 전용 규칙 - 성능 및 모범 사례
]

# 무시할 규칙들 - 중복 검사 방지 및 실용성 고려
ignore = [
    'E501', # 줄 길이 초과 - ruff format이 자동으로 처리하므로 중복
    'D',    # pydocstyle 전체 - docstring 검사는 선택적 (문서화 정책에 따라)
    'ANN',  # flake8-annotations 전체 - 타입 어노테이션은 mypy가 더 정확히 처리
]

# ===================================================================
# Import 정렬 세부 설정
# ===================================================================
[tool.ruff.lint.isort]
# Import 그룹 분리 (표준 라이브러리 → 서드파티 → 로컬)
force-sort-within-sections = true
# Trailing comma가 있을 때 import를 여러 줄로 분리
split-on-trailing-comma = true
# 같은 모듈의 from-import를 하나로 합치기
combine-as-imports = true
```

## inteliJ 통합
- https://plugins.jetbrains.com/plugin/20574-ruff 를 설치한다

# mypy
- 타입 체크 전문이다. `tsc` 비슷한 것이다.
## 설치
- [uv](https://github.com/astral-sh/uv) 기반 프로젝트에서 작업한다고 가정한다
```sh
uv add mypy --dev
```

```toml
# ===================================================================
# MyPy 설정 - 정적 타입 검사기로 런타임 오류 사전 방지
# ===================================================================
[tool.mypy]
# 대상 Python 버전 - 타입 시스템 기능 호환성 기준
python_version = '3.12'
# 패키지 기준점 명시 - 중복 모듈 오류 방지 (./main.py vs main.py 구분)
explicit_package_bases = true
# Any 타입 반환 경고 - 타입 안전성 향상 (너무 관대한 타입 사용 방지)
warn_return_any = true
# 사용되지 않는 MyPy 설정 경고 - 설정 파일 정리 유도
warn_unused_configs = true
# 변수 재정의 금지 - 실수로 같은 이름 변수 재할당 방지
allow_redefinition = false

# ===================================================================
# 타입 검사 엄격도 설정 - 프로젝트 성숙도에 따라 조정
# ===================================================================
# 타입 어노테이션 없는 함수 정의 허용 - 점진적 타입 도입을 위해 관대하게 설정
disallow_untyped_defs = false
# 타입 어노테이션 없는 함수 호출 허용 - 서드파티 라이브러리 호환성
disallow_untyped_calls = false
# Any 타입 표현식 허용 - 초기 개발 단계에서는 유연성 우선
disallow_any_expr = false
# 타입 정보 없는 라이브러리 무시 - 서드파티 라이브러리 호환성 (true = 무시)
ignore_missing_imports = true
# 타입 없는 함수의 내부 정의 체크 비활성화 - 개발 초기 단계에서 유연성 우선
check_untyped_defs = false
# 사용되지 않는 type: ignore 주석 경고 비활성화 - 점진적 타입 도입 과정 유연성
warn_unused_ignores = false
# 변수 타입 어노테이션 요구 완화 - LangChain 체인 등 복잡한 타입 처리
disallow_incomplete_defs = false

# 플러그인 설정 - Django, SQLAlchemy 등 프레임워크별 특수 처리 (현재 없음)
plugins = []

# ===================================================================
# 모듈별 예외 규칙 - 특정 모듈에 대한 맞춤 설정
# ===================================================================
# 테스트 파일 - 모든 타입 오류 무시 (테스트 코드는 유연성 우선)
[[tool.mypy.overrides]]
module = "tests.*"
ignore_errors = true

# 외부 패키지 - 타입 정보 없는 라이브러리 무시 (호환성 문제 방지)
[[tool.mypy.overrides]]
module = [
    'setuptools.*',    # 패키지 빌드 도구
    'distutils.*'      # 배포 유틸리티
]
ignore_missing_imports = true

# LangChain 라이브러리 - 타입 정의가 불완전하므로 관대하게 처리
[[tool.mypy.overrides]]
module = [
    'langchain_core.*',
    'langchain_openai.*',
]
ignore_errors = true
```
## inteliJ 통합
- https://plugins.jetbrains.com/plugin/25888-mypy

# pre-commit
- 허스키와 비슷하게. `pre-commit` 훅을 커밋할 수 있게 한다.
## 설치
- [uv](https://github.com/astral-sh/uv) 기반 프로젝트에서 작업한다고 가정한다
```sh
uv add pre-commit --dev
```
- git 의 pre-commit 과 연결
```sh
uv run pre-commit install
```
- 프로젝트 루트에 `.pre-commit-config.yaml` 을 추가. 
```yaml
repos:
  - repo: local
    hooks:
      - id: ruff-check
        name: ruff check
        entry: uv run ruff check --fix --unsafe-fixes
        language: system
        types: [python]
        # 수정 후 자동으로 staged 영역에 추가
        pass_filenames: false
        always_run: true

      - id: ruff-format
        name: ruff format
        entry: uv run ruff format
        language: system
        types: [python]
        # 수정 후 자동으로 staged 영역에 추가
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

# Makefile 생성 및 format 명령 구현 계획

실행 순서 분석

1. 최적의 실행 순서

1. uv run ruff check --fix --unsafe-fixes  # 린트 문제 자동 수정
2. uv run ruff format                      # 코드 포맷팅
3. uv run mypy .                          # 타입 체크

순서 선택 이유:
- Ruff check 먼저: import 순서, 미사용 변수 등 구조적 문제 해결
- Ruff format 다음: 코드 수정 후 일관된 포맷팅 적용
- MyPy 마지막: 정리된 코드에 대해 타입 검사 수행

2. Makefile 구조 계획

# 기본 설정
.PHONY: format lint type-check clean help
.DEFAULT_GOAL := help

# 메인 format 명령
format:
@echo "🔧 Running ruff check with fixes..."
uv run ruff check --fix --unsafe-fixes
@echo "✨ Running ruff format..."
uv run ruff format
@echo "🔍 Running mypy type check..."
uv run mypy .
@echo "✅ All formatting and checks completed!"

# 개별 명령들 (필요시 개별 실행용)
lint:
uv run ruff check --fix --unsafe-fixes

style:
uv run ruff format

type-check:
uv run mypy .

# 도움말
help:
@echo "Available commands:"
@echo "  format     - Run full code formatting pipeline"
@echo "  lint       - Run ruff linting with fixes"
@echo "  style      - Run ruff formatting only"
@echo "  type-check - Run mypy type checking only"

3. 추가 고려사항

에러 처리:
- 각 명령이 실패하면 전체 프로세스 중단
- Make의 기본 동작으로 자동 처리됨

확장 가능성:
- test: 테스트 실행
- clean: 캐시 파일 정리
- install: 의존성 설치
- pre-commit: Git hook 실행

사용법:
make format      # 전체 포맷팅 파이프라인
make lint        # 린팅만
make type-check  # 타입 체크만
make help        # 도움말
