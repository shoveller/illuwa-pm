#!/bin/bash

echo "🚀 pre-commit 설치 및 설정 중..."

# 패키지 매니저 감지 (uv 우선)
if command -v uv &> /dev/null && [ -f "pyproject.toml" ]; then
  echo "  uv project detected"
  install_cmd="uv add pre-commit --dev"
elif [ -f "poetry.lock" ]; then
  echo "  Poetry project detected"
  install_cmd="poetry add --group dev pre-commit"
elif [ -f "Pipfile" ]; then
  echo "  Pipenv project detected"
  install_cmd="pipenv install --dev pre-commit"
elif [ -n "$VIRTUAL_ENV" ]; then
  echo "  Virtual environment detected: $VIRTUAL_ENV"
  install_cmd="pip install pre-commit"
else
  echo "  Using system pip (권장: uv 또는 가상환경 사용)"
  install_cmd="pip install pre-commit"
fi

# pre-commit 설치
echo "  Installing pre-commit with: $install_cmd"
eval $install_cmd

# .pre-commit-config.yaml 생성 (python-recipe.md 기반)
if [ -f ".pre-commit-config.yaml" ]; then
  echo "  Backing up existing .pre-commit-config.yaml to .pre-commit-config.yaml.backup"
  cp .pre-commit-config.yaml .pre-commit-config.yaml.backup
fi

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

# git hooks 설치
if git rev-parse --git-dir > /dev/null 2>&1; then
  echo "  Installing pre-commit hooks to git..."
  if command -v uv &> /dev/null && [ -f "pyproject.toml" ]; then
    uv run pre-commit install
  elif [ -f "poetry.lock" ]; then
    poetry run pre-commit install
  elif [ -f "Pipfile" ]; then
    pipenv run pre-commit install
  else
    pre-commit install
  fi
  echo "  ✅ Pre-commit hooks installed successfully!"
else
  echo "  ⚠️ Not a git repository, skipping hook installation"
  echo "  Run 'git init' first, then 'uv run pre-commit install'"
fi

echo ""
echo "  ✅ pre-commit 설정이 완료되었습니다!"
echo "  사용법:"
echo "    uv run pre-commit install     # Git hooks 설치"
echo "    uv run pre-commit run --all   # 모든 파일에 대해 실행"
echo "    git commit                    # 커밋 시 자동 실행"
echo ""
echo "  추가 정보:"
echo "    - .pre-commit-config.yaml 파일이 생성되었습니다"
echo "    - 커밋할 때마다 Ruff check, format, MyPy가 자동 실행됩니다"
echo "    - 코드가 자동으로 수정되고 staged 영역에 추가됩니다"