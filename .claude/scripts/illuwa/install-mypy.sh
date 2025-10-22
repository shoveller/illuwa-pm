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
# 타입 정보 없는 라이브러리 무시 - 서드파티 라이브러리 호환성
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
# ===================================================================
# MyPy 설정 - 정적 타입 검사기로 런타임 오류 사전 방지
# ===================================================================
# 대상 Python 버전 - 타입 시스템 기능 호환성 기준
python_version = 3.12
# 패키지 기준점 명시 - 중복 모듈 오류 방지 (./main.py vs main.py 구분)
explicit_package_bases = True
# Any 타입 반환 경고 - 타입 안전성 향상 (너무 관대한 타입 사용 방지)
warn_return_any = True
# 사용되지 않는 MyPy 설정 경고 - 설정 파일 정리 유도
warn_unused_configs = True
# 변수 재정의 금지 - 실수로 같은 이름 변수 재할당 방지
allow_redefinition = False

# ===================================================================
# 타입 검사 엄격도 설정 - 프로젝트 성숙도에 따라 조정
# ===================================================================
# 타입 어노테이션 없는 함수 정의 허용 - 점진적 타입 도입을 위해 관대하게 설정
disallow_untyped_defs = False
# 타입 어노테이션 없는 함수 호출 허용 - 서드파티 라이브러리 호환성
disallow_untyped_calls = False
# Any 타입 표현식 허용 - 초기 개발 단계에서는 유연성 우선
disallow_any_expr = False
# 타입 정보 없는 라이브러리 무시 - 서드파티 라이브러리 호환성
ignore_missing_imports = True
# 타입 없는 함수의 내부 정의 체크 비활성화 - 개발 초기 단계에서 유연성 우선
check_untyped_defs = False
# 사용되지 않는 type: ignore 주석 경고 비활성화 - 점진적 타입 도입 과정 유연성
warn_unused_ignores = False
# 변수 타입 어노테이션 요구 완화 - LangChain 체인 등 복잡한 타입 처리
disallow_incomplete_defs = False

# ===================================================================
# 모듈별 예외 규칙 - 특정 모듈에 대한 맞춤 설정
# ===================================================================
# 외부 패키지 - 타입 정보 없는 라이브러리 무시 (호환성 문제 방지)
[mypy-setuptools.*]
ignore_missing_imports = True

[mypy-distutils.*]
ignore_missing_imports = True

# 테스트 파일 - 모든 타입 오류 무시 (테스트 코드는 유연성 우선)
[mypy-tests.*]
ignore_errors = True

# LangChain 라이브러리 - 타입 정의가 불완전하므로 관대하게 처리
[mypy-langchain_core.*]
ignore_errors = True

[mypy-langchain_openai.*]
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