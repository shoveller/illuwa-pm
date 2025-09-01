#!/bin/bash

echo "🐕 Husky Git Hooks 설치 및 설정 중..."

# pnpm 사용 (CLAUDE.md 설정에 따라)
if command -v pnpm &> /dev/null; then
  echo "  Using pnpm package manager"
  
  # Husky 설치
  echo "  Installing Husky..."
  pnpm add -D husky
  
  # Husky 초기화 
  echo "  Initializing Husky..."
  pnpm husky init
  
  # npm-run-all 설치
  echo "  Installing npm-run-all..."
  pnpm add -D npm-run-all

elif command -v npm &> /dev/null; then
  echo "  Using npm package manager"
  npm install --save-dev husky
  npx husky init
  npm install --save-dev npm-run-all

else
  echo "  ❌ pnpm or npm not found"
  exit 1
fi

# package.json scripts 확인 및 추가
echo "  Checking and adding required scripts to package.json..."

if command -v jq &> /dev/null; then
  # ESLint 스크립트 확인/추가
  if ! jq -e '.scripts.eslint' package.json >/dev/null 2>&1; then
    echo "    Adding eslint script..."
    jq '.scripts.eslint = "eslint --fix --ignore-pattern .gitignore --cache --cache-location ./node_modules/.cache/eslint ."' package.json > package.json.tmp && mv package.json.tmp package.json
  fi
  
  # Prettier 스크립트 확인/추가
  if ! jq -e '.scripts.prettier' package.json >/dev/null 2>&1; then
    echo "    Adding prettier script..."
    jq '.scripts.prettier = "prettier --write \"**/*.{ts,tsx,cjs,mjs,json,html,css,js,jsx}\" --cache"' package.json > package.json.tmp && mv package.json.tmp package.json
  fi
  
  # TypeScript 체크 스크립트 확인/추가
  if ! jq -e '.scripts["type:check"]' package.json >/dev/null 2>&1; then
    echo "    Adding type:check script..."
    jq '.scripts["type:check"] = "tsc --noEmit"' package.json > package.json.tmp && mv package.json.tmp package.json
  fi
  
  # Format 통합 스크립트 추가
  echo "    Adding integrated format script..."
  jq '.scripts.format = "run-s type:check prettier eslint"' package.json > package.json.tmp && mv package.json.tmp package.json

else
  echo "  jq not available, please manually add these scripts to package.json:"
  echo "    \"eslint\": \"eslint --fix --ignore-pattern .gitignore --cache --cache-location ./node_modules/.cache/eslint .\""
  echo "    \"prettier\": \"prettier --write \\\"**/*.{ts,tsx,cjs,mjs,json,html,css,js,jsx}\\\" --cache\""
  echo "    \"type:check\": \"tsc --noEmit\""
  echo "    \"format\": \"run-s type:check prettier eslint\""
fi

# .husky/pre-commit 파일 설정
if [ -f ".husky/pre-commit" ]; then
  echo "  Updating .husky/pre-commit..."
  cat > .husky/pre-commit << 'EOF'
pnpm format
EOF
else
  echo "  .husky/pre-commit not found, creating..."
  mkdir -p .husky
  cat > .husky/pre-commit << 'EOF'
pnpm format
EOF
  chmod +x .husky/pre-commit
fi

echo ""
echo "  ✅ Husky Git Hooks 설정이 완료되었습니다!"
echo "  레시피 특징:"
echo "    ✨ Git pre-commit hook 자동 실행"
echo "    ✨ TypeScript 타입 체크 + Prettier + ESLint 통합"
echo "    ✨ npm-run-all 을 사용한 순차 실행"
echo "    ✨ 커밋 전 자동 코드 품질 검사"
echo ""
echo "  설정된 워크플로우:"
echo "    1. git commit 시도"
echo "    2. TypeScript 타입 체크 실행"
echo "    3. Prettier 포맷팅 적용"
echo "    4. ESLint 린트 검사 및 자동 수정"
echo "    5. 모든 단계 성공 시 커밋 완료"
echo ""
echo "  사용법:"
echo "    pnpm format      # 수동으로 전체 포맷팅 실행"
echo "    git commit       # 자동으로 pre-commit hook 실행"