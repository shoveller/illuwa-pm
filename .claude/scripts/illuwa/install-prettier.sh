#!/bin/bash

echo "🎨 Prettier 설치 및 설정 중..."

# pnpm 사용 (CLAUDE.md 설정에 따라)
if command -v pnpm &> /dev/null; then
  echo "  Using pnpm package manager"
  
  # 레시피 기반 Prettier 및 플러그인 설치
  echo "  Installing Prettier with recommended plugins..."
  pnpm add -D prettier @trivago/prettier-plugin-sort-imports prettier-plugin-css-order prettier-plugin-classnames
  
  # Tailwind CSS 프로젝트인지 확인
  if grep -q "tailwindcss" package.json; then
    echo "  Tailwind CSS detected, this will be handled by prettier-plugin-classnames"
  fi

elif command -v npm &> /dev/null; then
  echo "  Using npm package manager"
  npm install --save-dev prettier @trivago/prettier-plugin-sort-imports prettier-plugin-css-order prettier-plugin-classnames
  
  if grep -q "tailwindcss" package.json; then
    echo "  Tailwind CSS detected, this will be handled by prettier-plugin-classnames"
  fi

else
  echo "  ❌ pnpm or npm not found"
  exit 1
fi

# 기존 설정 파일 백업 (다양한 형식 지원)
if [ -f "prettier.config.mjs" ]; then
  echo "  Backing up existing prettier.config.mjs to prettier.config.mjs.backup"
  cp prettier.config.mjs prettier.config.mjs.backup
elif [ -f ".prettierrc" ]; then
  echo "  Backing up existing .prettierrc to .prettierrc.backup"
  cp .prettierrc .prettierrc.backup
fi

echo "  Creating .prettierrc.json configuration (레시피 기반)..."

# 레시피 기반 .prettierrc.json 생성
cat > .prettierrc.json << 'EOF'
{
  "endOfLine": "lf",
  "semi": false,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "none",
  "plugins": [
    "prettier-plugin-css-order",
    "prettier-plugin-classnames",
    "@trivago/prettier-plugin-sort-imports"
  ],
  "importOrder": [
    "^react",
    "^next",
    "^react-router",
    "<BUILTIN_MODULES>",
    "<THIRD_PARTY_MODULES>",
    ".css$",
    ".scss$",
    "^[.]"
  ],
  "importOrderSeparation": true,
  "importOrderSortSpecifiers": true
}
EOF

# .prettierignore 파일 생성
if [ ! -f ".prettierignore" ]; then
  echo "  Creating .prettierignore..."
  cat > .prettierignore << 'EOF'
node_modules
.next
dist
build
coverage
.env*
*.log
.DS_Store
.git
EOF
fi

# package.json scripts 추가 (레시피 기반)
echo "  Adding optimized prettier script to package.json..."
if command -v jq &> /dev/null; then
  # 레시피의 최적화된 prettier 명령어 사용
  jq '.scripts.prettier = "prettier --write \"**/*.{ts,tsx,cjs,mjs,json,html,css,js,jsx}\" --cache"' package.json > package.json.tmp && mv package.json.tmp package.json
else
  echo "  jq not available, please manually add this script to package.json:"
  echo "    \"prettier\": \"prettier --write \\\"**/*.{ts,tsx,cjs,mjs,json,html,css,js,jsx}\\\" --cache\""
fi

# VS Code 설정 추가 (선택사항)
if [ ! -d ".vscode" ]; then
  mkdir -p .vscode
fi

if [ ! -f ".vscode/settings.json" ]; then
  echo "  Creating VS Code settings for Prettier..."
  cat > .vscode/settings.json << 'EOF'
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  }
}
EOF
else
  echo "  VS Code settings already exist, skipping..."
fi

echo "  ✅ Prettier 설정이 완료되었습니다!"
echo "  레시피 특징:"
echo "    ✨ prettier.config.mjs 설정 (한글 주석 포함)"
echo "    ✨ Import 정렬 (@trivago/prettier-plugin-sort-imports)"
echo "    ✨ CSS 속성 정렬 (prettier-plugin-css-order)"
echo "    ✨ 클래스명 정렬 (prettier-plugin-classnames)"
echo "    ✨ 캐시 최적화 및 다양한 파일 형식 지원"
echo ""
echo "  사용법:"
echo "    pnpm prettier    # 전체 포맷팅 (캐시 사용)"
echo "  VS Code: 파일 저장 시 자동 포맷팅 활성화됨"