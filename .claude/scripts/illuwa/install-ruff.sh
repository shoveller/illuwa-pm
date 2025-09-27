#!/bin/bash

echo "🔧 Ruff 설치 및 설정 중..."

# 패키지 매니저 감지 (uv 우선)
if command -v uv &> /dev/null && [ -f "pyproject.toml" ]; then
  echo "  uv project detected"
  install_cmd="uv add ruff --dev"
elif [ -f "poetry.lock" ]; then
  echo "  Poetry project detected"
  install_cmd="poetry add --group dev ruff"
elif [ -f "Pipfile" ]; then
  echo "  Pipenv project detected"
  install_cmd="pipenv install --dev ruff"
elif [ -n "$VIRTUAL_ENV" ]; then
  echo "  Virtual environment detected: $VIRTUAL_ENV"
  install_cmd="pip install ruff"
else
  echo "  Using system pip (권장: uv 또는 가상환경 사용)"
  install_cmd="pip install ruff"
fi

# Ruff 설치
echo "  Installing Ruff with: $install_cmd"
eval $install_cmd

# pyproject.toml 설정 (있으면 업데이트, 없으면 생성)
if [ -f "pyproject.toml" ]; then
  echo "  Updating existing pyproject.toml..."
  
  # Ruff 설정이 이미 있는지 확인
  if grep -q "\[tool.ruff\]" pyproject.toml; then
    echo "  Ruff configuration already exists in pyproject.toml"
  else
    echo "  Adding Ruff configuration to pyproject.toml..."
    cat >> pyproject.toml << 'EOF'

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
    'C4',  # flake8-comprehensions - list/dict comprehension 최적화
    'SIM', # flake8-simplify - 코드 단순화 제안
    'RET', # flake8-return - return 문 스타일 개선
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
# 각 그룹 사이에 빈 줄 추가
split-on-trailing-comma = true
# from import 합치기
combine-as-imports = true
EOF
  fi
else
  echo "  Creating pyproject.toml with Ruff configuration..."
  cat > pyproject.toml << 'EOF'
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
EOF
fi


# VS Code 설정 추가
if [ ! -d ".vscode" ]; then
  mkdir -p .vscode
fi

if [ ! -f ".vscode/settings.json" ]; then
  echo "  Creating VS Code settings for Ruff..."
  cat > .vscode/settings.json << 'EOF'
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
EOF
else
  echo "  VS Code settings already exist, please manually add Ruff configuration"
fi

echo "  ✅ Ruff 설정이 완료되었습니다!"
echo "  사용법:"
echo "    ruff check .              # 린트 검사"
echo "    ruff check . --fix        # 자동 수정"
echo "    ruff format .             # 코드 포맷팅"
echo "    ruff check . --watch      # 파일 변경 감시"
echo ""
echo "  추가 정보:"
echo "    - pyproject.toml에 설정이 추가되었습니다"
echo "    - VS Code에서 자동 포맷팅이 활성화됩니다"
echo "    - Ruff는 Black, isort, Flake8을 대체합니다"
