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
indent-width = 2

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
# 패키지 기준점 명시 - 중복 모듈 오류 방지
explicit_package_bases = true
# 네임스페이스 패키지 사용 - 모듈 구조 명확화
namespace_packages = true
# Any 타입 반환 경고 - 타입 안전성 향상
warn_return_any = true
# 사용되지 않는 MyPy 설정 경고 - 설정 파일 정리 유도
warn_unused_configs = true
# 변수 재정의 금지 - 실수로 같은 이름 변수 재할당 방지
allow_redefinition = false
# 검사할 파일 패턴 명시 - 불필요한 파일 제외
files = ["*.py"]
# 제외할 패턴 - 임시 파일, 빌드 파일 등
exclude = [
    "build/",
    "dist/",
    ".venv/",
    "__pycache__/",
    ".*\\.egg-info/",
]

# ===================================================================
# 타입 검사 엄격도 설정 - 프로젝트 성숙도에 따라 조정
# ===================================================================
# 타입 어노테이션 없는 함수 정의 허용 - 점진적 타입 도입
disallow_untyped_defs = false
# 타입 어노테이션 없는 함수 호출 허용 - 서드파티 라이브러리 호환성
disallow_untyped_calls = false
# Any 타입 표현식 허용 - 초기 개발 단계에서는 유연성 우선
disallow_any_expr = false
# 타입 정보 없는 라이브러리 체크 시도 - 가능한 모든 타입 오류 감지
ignore_missing_imports = false

# 플러그인 설정 - 현재 없음
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
