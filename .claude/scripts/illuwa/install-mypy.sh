#!/bin/bash

echo "🔍 MyPy 설치 및 설정 중..."

# 패키지 매니저 감지 (uv 우선)
if command -v uv &> /dev/null && [ -f "pyproject.toml" ]; then
  echo "  uv project detected"
  install_cmd="uv add mypy --dev"
  install_types_cmd="uv add types-requests types-urllib3 types-PyYAML --dev"
elif [ -f "poetry.lock" ]; then
  echo "  Poetry project detected"
  install_cmd="poetry add --group dev mypy"
  install_types_cmd="poetry add --group dev types-requests types-urllib3 types-PyYAML"
elif [ -f "Pipfile" ]; then
  echo "  Pipenv project detected"
  install_cmd="pipenv install --dev mypy"
  install_types_cmd="pipenv install --dev types-requests types-urllib3 types-PyYAML"
elif [ -n "$VIRTUAL_ENV" ]; then
  echo "  Virtual environment detected: $VIRTUAL_ENV"
  install_cmd="pip install mypy"
  install_types_cmd="pip install types-requests types-urllib3 types-PyYAML"
else
  echo "  Using system pip (권장: uv 또는 가상환경 사용)"
  install_cmd="pip install mypy"
  install_types_cmd="pip install types-requests types-urllib3 types-PyYAML"
fi

# MyPy 설치
echo "  Installing MyPy with: $install_cmd"
eval $install_cmd
echo "  Installing common type stubs..."
eval $install_types_cmd

# Django 프로젝트 감지
if [ -f "manage.py" ] && (grep -q "django" requirements.txt 2>/dev/null || grep -q "Django" pyproject.toml 2>/dev/null); then
  echo "  Django project detected, installing django-stubs..."
  if command -v uv &> /dev/null && [ -f "pyproject.toml" ]; then
    uv add django-stubs --dev
  elif [ -f "poetry.lock" ]; then
    poetry add --group dev django-stubs
  elif [ -f "Pipfile" ]; then
    pipenv install --dev django-stubs
  else
    pip install django-stubs
  fi
fi

# FastAPI 프로젝트 감지
if grep -q "fastapi" requirements.txt 2>/dev/null || grep -q "fastapi" pyproject.toml 2>/dev/null; then
  echo "  FastAPI project detected, installing additional type stubs..."
  if command -v uv &> /dev/null && [ -f "pyproject.toml" ]; then
    uv add types-pydantic --dev
  elif [ -f "poetry.lock" ]; then
    poetry add --group dev types-pydantic
  elif [ -f "Pipfile" ]; then
    pipenv install --dev types-pydantic
  else
    pip install types-pydantic
  fi
fi

# mypy.ini 설정 파일 생성 (있으면 백업)
if [ -f "mypy.ini" ]; then
  echo "  Backing up existing mypy.ini to mypy.ini.backup"
  cp mypy.ini mypy.ini.backup
fi

# pyproject.toml이 있으면 그곳에 설정 추가, 없으면 mypy.ini 생성
if [ -f "pyproject.toml" ]; then
  echo "  Adding MyPy configuration to pyproject.toml..."
  
  # MyPy 설정이 이미 있는지 확인
  if grep -q "\[tool.mypy\]" pyproject.toml; then
    echo "  MyPy configuration already exists in pyproject.toml"
  else
    cat >> pyproject.toml << 'EOF'

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

# Django 프로젝트인 경우
plugins = []

[[tool.mypy.overrides]]
module = "tests.*"
ignore_errors = true

# 외부 라이브러리 무시
[[tool.mypy.overrides]]
module = [
    "setuptools.*",
    "distutils.*"
]
ignore_missing_imports = true
EOF

    # Django 감지시 플러그인 추가
    if [ -f "manage.py" ]; then
      sed -i 's/plugins = \[\]/plugins = ["mypy_django_plugin.main"]/' pyproject.toml
    fi
  fi
else
  echo "  Creating mypy.ini configuration..."
  cat > mypy.ini << 'EOF'
[mypy]
# 타입 체크 설정 - Final 재할당 등 엄격한 체크
python_version = 3.12
warn_return_any = True
warn_unused_configs = True
# Final 변수 재할당을 에러로 처리
allow_redefinition = False
# 엄격한 타입 체크 - 변수 재할당 방지 (strict 제거하고 개별 설정)
disallow_untyped_defs = False
# 반환 타입은 추론에 의존
disallow_untyped_calls = False
disallow_any_expr = False
# 타입이 없는 라이브러리도 체크
ignore_missing_imports = False

# 외부 라이브러리 무시
[mypy-setuptools.*]
ignore_missing_imports = True

[mypy-distutils.*]
ignore_missing_imports = True

# 테스트 디렉토리는 덜 엄격하게
[mypy-tests.*]
ignore_errors = True
EOF

  # Django 감지시 플러그인 추가
  if [ -f "manage.py" ]; then
    echo "" >> mypy.ini
    echo "plugins = mypy_django_plugin.main" >> mypy.ini
  fi
fi

# py.typed 파일 생성 (패키지의 경우)
if [ -d "src" ]; then
  echo "  Creating py.typed marker files..."
  find src -name "*.py" -exec dirname {} \; | sort -u | while read dir; do
    if [ ! -f "$dir/py.typed" ]; then
      touch "$dir/py.typed"
    fi
  done
fi

# VS Code 설정 추가
if [ ! -d ".vscode" ]; then
  mkdir -p .vscode
fi

if [ -f ".vscode/settings.json" ]; then
  echo "  VS Code settings already exist, please manually add MyPy configuration"
else
  echo "  Creating VS Code settings for MyPy..."
  cat > .vscode/settings.json << 'EOF'
{
  "python.linting.enabled": true,
  "python.linting.mypyEnabled": true,
  "python.linting.mypyArgs": [
    "--strict",
    "--show-error-codes"
  ],
  "python.analysis.typeCheckingMode": "strict"
}
EOF
fi

# pre-commit hook 생성 (python-recipe.md 기반)
if [ -f ".pre-commit-config.yaml" ]; then
  echo "  .pre-commit-config.yaml exists, consider adding hooks manually"
else
  echo "  Creating .pre-commit-config.yaml with Ruff + MyPy hooks..."
  cat > .pre-commit-config.yaml << 'EOF'
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
EOF
fi

echo "  ✅ MyPy 설정이 완료되었습니다!"
echo "  사용법:"
echo "    mypy .                    # 전체 프로젝트 타입 검사"
echo "    mypy src/                 # src 디렉토리만 검사"
echo "    mypy --strict .           # 엄격한 검사"
echo "    mypy --install-types      # 누락된 타입 스텁 자동 설치"
echo ""
echo "  추가 정보:"
echo "    - 설정이 pyproject.toml 또는 mypy.ini에 추가되었습니다"
echo "    - VS Code에서 타입 검사가 활성화됩니다"
echo "    - 점진적 타이핑을 위해 --strict 옵션 사용을 권장합니다"