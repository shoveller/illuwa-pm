#!/bin/bash

echo "🆚 VSCode 설정 파일 생성 중..."
echo "=============================="

# .vscode 디렉토리가 없으면 생성
if [ ! -d ".vscode" ]; then
  echo "📁 .vscode 디렉토리 생성 중..."
  mkdir -p .vscode
fi

# extensions.json 생성 또는 업데이트
echo "🔌 VSCode 확장 프로그램 권장 설정 중..."
cat > .vscode/extensions.json << 'EOF'
{
  "recommendations": ["dbaeumer.vscode-eslint", "esbenp.prettier-vscode"]
}
EOF
echo "✅ .vscode/extensions.json 파일이 생성되었습니다"

# settings.json 생성 또는 업데이트
echo "⚙️ VSCode 설정 파일 생성 중..."
cat > .vscode/settings.json << 'EOF'
{
  "explorer.compactFolders": false,
  "typescript.tsdk": "node_modules/typescript/lib",
  "prettier.prettierPath": "./node_modules/prettier",
  "prettier.configPath": "prettier.config.mjs",
  "eslint.options": {
    "overrideConfigFile": "eslint.config.mjs"
  },
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": "explicit"
  },
  "[javascript]": {
    "editor.formatOnSave": true,
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[typescript]": {
    "editor.formatOnSave": true,
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "local-history.browser.descending": false
}
EOF
echo "✅ .vscode/settings.json 파일이 생성되었습니다"

echo ""
echo "✅ VSCode 설정이 완료되었습니다."
echo "   권장 확장 프로그램:"
echo "   - ESLint (dbaeumer.vscode-eslint)"
echo "   - Prettier (esbenp.prettier-vscode)"