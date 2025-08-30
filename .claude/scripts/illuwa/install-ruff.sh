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
EOF
  fi
else
  echo "  Creating pyproject.toml with Ruff configuration..."
  cat > pyproject.toml << 'EOF'
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
EOF
fi

# .ruff.toml 파일 생성 (독립 설정 파일로도 사용 가능)
if [ ! -f ".ruff.toml" ]; then
  echo "  Creating .ruff.toml as backup configuration..."
  cat > .ruff.toml << 'EOF'
target-version = "py38"
line-length = 88

[lint]
select = [
    "E",  # pycodestyle errors
    "W",  # pycodestyle warnings
    "F",  # pyflakes
    "I",  # isort
    "B",  # flake8-bugbear
    "C4", # flake8-comprehensions
    "UP", # pyupgrade
]
ignore = [
    "E501",  # line too long, handled by black
    "B008",  # do not perform function calls in argument defaults
    "C901",  # too complex
]

[lint.per-file-ignores]
"__init__.py" = ["F401"]
"test_*.py" = ["B018"]

[lint.isort]
known-first-party = ["src"]
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