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
[tool.ruff]
# Python 버전 대상 설정 - 최신 기능/문법 체크 기준
target-version = "py312"
# 한 줄 최대 길이 - 코드 가독성을 위한 제한
line-length = 88
# 들여쓰기 칸수 - 일관된 코드 스타일을 위함
indent-width = 2

[tool.ruff.format]
# 문자열 따옴표 스타일 - 일관성을 위해 작은따옴표 사용
quote-style = "single"
# 줄바꿈 문자 - Unix 스타일(LF) 강제로 OS 간 호환성 확보
line-ending = "lf"

[tool.ruff.lint]
# 활성화할 린팅 규칙들 - 코드 품질과 버그 방지
select = [
    "E", # 코딩 스타일 오류 (들여쓰기, 공백 등)
    "W", # 코딩 스타일 경고 (불필요한 공백 등)
    "F", # 논리 오류 (사용하지 않는 변수, import 등)
    "I", # import 문 정렬 - 깔끔한 import 순서 유지
    "UP", # 구식 Python 문법을 현대적으로 업데이트
    "B", # 흔한 버그 패턴 감지 (무한루프, 잘못된 비교 등)
    "RUF", # Ruff 전용 규칙들
]

# 무시할 규칙들 - 포맷터가 처리하므로 중복 체크 방지
ignore = [
    "E501", # 줄 길이 초과 - ruff format이 자동 처리
    "D", # docstring 관련 제외
    "ANN", # type annotation 관련 (mypy가 처리)
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
[tool.mypy]
# 타입 체크 설정 - Final 재할당 등 엄격한 체크
python_version = "3.12"
warn_return_any = true
warn_unused_configs = true
# Final 변수 재할당을 에러로 처리
allow_redefinition = false
# 엄격한 타입 체크 - 변수 재할당 방지 (strict 제거하고 개별 설정)
disallow_untyped_defs = false
# 반환 타입은 추론에 의존
disallow_untyped_calls = false
disallow_any_expr = false
# 타입이 없는 라이브러리도 체크
ignore_missing_imports = false
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
          entry: uv run ruff check --fix
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
          entry: uv run mypy
          language: system
          types: [python]
```
