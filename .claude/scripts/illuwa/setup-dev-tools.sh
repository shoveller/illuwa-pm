#!/bin/bash

echo "🔍 프로젝트 타입 감지 중..."
echo "======================================"

# Git 기본 설정
if [ -f ".claude/scripts/illuwa/modify-git.sh" ]; then
  echo "📝 Git 기본 설정 중..."
  bash .claude/scripts/illuwa/modify-git.sh
  echo ""
fi

# Node.js 프로젝트 감지
if [ -f "package.json" ]; then
  echo "📦 Node.js 프로젝트가 감지되었습니다"
  echo ""
  
  if [ -f ".claude/scripts/illuwa/install-tsconfig.sh" ]; then
    echo "⚙️ TypeScript 설정 중..."
    bash .claude/scripts/illuwa/install-tsconfig.sh
    echo ""
  fi
  
  if [ -f ".claude/scripts/illuwa/install-prettier.sh" ]; then
    echo "🎨 Prettier 설정 중..."
    bash .claude/scripts/illuwa/install-prettier.sh
    echo ""
  fi
  
  if [ -f ".claude/scripts/illuwa/install-eslint.sh" ]; then
    echo "🔧 ESLint 설정 중..."
    bash .claude/scripts/illuwa/install-eslint.sh
    echo ""
  fi
  
  if [ -f ".claude/scripts/illuwa/install-husky.sh" ]; then
    echo "🐕 Husky Git Hooks 설정 중..."
    bash .claude/scripts/illuwa/install-husky.sh
    echo ""
  fi

  # Next.js 프로젝트 확인 (package.json에서 next 의존성 확인)
  if grep -q '"next"' package.json 2>/dev/null; then
    echo "⚛️ Next.js 프로젝트가 감지되었습니다"
    if [ -f ".claude/scripts/illuwa/modify-nextjs.sh" ]; then
      echo "🎨 Next.js CSS 타입 설정 중..."
      bash .claude/scripts/illuwa/modify-nextjs.sh
      echo ""
    fi
  fi

  # VSCode 설정 파일 생성
  if [ -f ".claude/scripts/illuwa/modify-vscode.sh" ]; then
    echo "🆚 VSCode 설정 중..."
    bash .claude/scripts/illuwa/modify-vscode.sh
    echo ""
  fi

# Python 프로젝트 감지
elif [ -f "pyproject.toml" ] || [ -f "requirements.txt" ] || [ -f "setup.py" ]; then
  echo "🐍 Python 프로젝트가 감지되었습니다"
  echo ""
  
  if [ -f ".claude/scripts/illuwa/install-ruff.sh" ]; then
    echo "🔧 Ruff 설정 중..."
    bash .claude/scripts/illuwa/install-ruff.sh
    echo ""
  fi
  
  if [ -f ".claude/scripts/illuwa/install-mypy.sh" ]; then
    echo "🔍 MyPy 설정 중..."
    bash .claude/scripts/illuwa/install-mypy.sh
    echo ""
  fi
  
  if [ -f ".claude/scripts/illuwa/install-precommit.sh" ]; then
    echo "🚀 pre-commit 설정 중..."
    bash .claude/scripts/illuwa/install-precommit.sh
    echo ""
  fi

else
  echo "❓ 알 수 없는 프로젝트 타입입니다"
  echo "   지원하는 프로젝트 타입:"
  echo "   - Node.js (package.json)"
  echo "   - Python (pyproject.toml, requirements.txt, setup.py)"
  echo "   자동 설정을 건너뜁니다."
  echo ""
fi

echo "✅ 개발 도구 설정이 완료되었습니다."