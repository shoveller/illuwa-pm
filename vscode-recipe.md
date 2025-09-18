# vscode 계열 IDE를 위한 prettier,eslint 플러그인 설정
- 아래의 vscode 설정을 추가해서 인간의 생산성을 높인다.
- `dbaeumer.vscode-eslint` , `esbenp.prettier-vscode` 를 권장 플러그인으로 표시해서 설치를 유도한다.
- .vscode/extensions.json`
```json
{
  "recommendations": ["dbaeumer.vscode-eslint", "esbenp.prettier-vscode"]
}
```

- `dbaeumer.vscode-eslint` , `esbenp.prettier-vscode` 의 사용을 강제한다.
- `.vscode/settings.json`
```json
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
```