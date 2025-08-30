#!/bin/bash

echo "📦 ESLint 설치 및 설정 중..."

# pnpm 사용 (CLAUDE.md 설정에 따라)
if command -v pnpm &> /dev/null; then
  echo "  Using pnpm package manager"
  
  # 프로젝트 타입 감지
  IS_NEXT=$(grep -q "\"next\"" package.json && echo "true" || echo "false")
  IS_REMIX=$(grep -q "@remix-run" package.json && echo "true" || echo "false")
  IS_REACT=$(grep -q "\"react\"" package.json && echo "true" || echo "false")
  
  if [ "$IS_NEXT" = "true" ]; then
    echo "  Next.js 15 project detected"
    echo "  Installing Next.js ESLint packages..."
    pnpm add -D eslint @eslint/eslintrc eslint-plugin-react-hooks @next/eslint-plugin-next eslint-plugin-functional eslint-plugin-unused-imports typescript-eslint
  elif [ "$IS_REMIX" = "true" ]; then
    echo "  Remix 3 project detected"  
    echo "  Installing Remix ESLint packages..."
    pnpm add -D eslint @eslint/js typescript-eslint eslint-plugin-functional eslint-plugin-unused-imports eslint-plugin-react-hooks
    pnpm add -D eslint-plugin-react-refresh
    pnpm add -D globals
  elif [ "$IS_REACT" = "true" ]; then
    echo "  React project detected"
    echo "  Installing React ESLint packages..."
    pnpm add -D eslint @eslint/js eslint-plugin-react eslint-plugin-react-hooks typescript-eslint eslint-plugin-functional eslint-plugin-unused-imports
    pnpm add -D eslint-plugin-react-refresh
    pnpm add -D globals
  else
    echo "  TypeScript project detected"
    echo "  Installing TypeScript ESLint packages..."
    pnpm add -D eslint @eslint/js typescript-eslint eslint-plugin-functional eslint-plugin-unused-imports
  fi

elif command -v npm &> /dev/null; then
  echo "  Using npm package manager"
  
  # 프로젝트 타입 감지 (npm 버전)
  IS_NEXT=$(grep -q "\"next\"" package.json && echo "true" || echo "false")
  IS_REMIX=$(grep -q "@remix-run" package.json && echo "true" || echo "false")
  IS_REACT=$(grep -q "\"react\"" package.json && echo "true" || echo "false")
  
  if [ "$IS_NEXT" = "true" ]; then
    npm install --save-dev eslint @eslint/eslintrc eslint-plugin-react-hooks @next/eslint-plugin-next eslint-plugin-functional eslint-plugin-unused-imports typescript-eslint
  elif [ "$IS_REMIX" = "true" ]; then
    npm install --save-dev eslint @eslint/js typescript-eslint eslint-plugin-functional eslint-plugin-unused-imports eslint-plugin-react-hooks
    npm install --save-dev eslint-plugin-react-refresh
    npm install --save-dev globals
  elif [ "$IS_REACT" = "true" ]; then
    npm install --save-dev eslint @eslint/js eslint-plugin-react eslint-plugin-react-hooks typescript-eslint eslint-plugin-functional eslint-plugin-unused-imports
    npm install --save-dev eslint-plugin-react-refresh
    npm install --save-dev globals
  else
    npm install --save-dev eslint @eslint/js typescript-eslint eslint-plugin-functional eslint-plugin-unused-imports
  fi

else
  echo "  ❌ pnpm or npm not found"
  exit 1
fi

# 기존 설정 파일 백업
if [ -f "eslint.config.mjs" ]; then
  echo "  Backing up existing eslint.config.mjs to eslint.config.mjs.backup"
  cp eslint.config.mjs eslint.config.mjs.backup
elif [ -f ".eslintrc.js" ]; then
  echo "  Backing up existing .eslintrc.js to .eslintrc.js.backup"
  cp .eslintrc.js .eslintrc.js.backup
fi

# 프로젝트 타입에 따른 Flat Config 생성
IS_NEXT=$(grep -q "\"next\"" package.json && echo "true" || echo "false")
IS_REMIX=$(grep -q "\"react-router\"" package.json && echo "true" || echo "false")

if [ "$IS_NEXT" = "true" ]; then
  echo "  Creating Next.js 15 flat config (eslint.config.mjs)..."
  cat > eslint.config.mjs << 'EOF'
import { dirname } from 'path'
import { fileURLToPath } from 'url'
import { FlatCompat } from '@eslint/eslintrc'
import functional from 'eslint-plugin-functional'
import unusedImports from 'eslint-plugin-unused-imports'
import tseslint from 'typescript-eslint'
import { globalIgnores } from 'eslint/config'

// eslint-disable-next-line @typescript-eslint/no-shadow
const __filename = fileURLToPath(import.meta.url)
// eslint-disable-next-line @typescript-eslint/no-shadow
const __dirname = dirname(__filename)

const compat = new FlatCompat({
  baseDirectory: __dirname
})

const functionalStyles = {
  plugins: {
    functional
  },
  rules: {
    // 변수 선언 관련
    'functional/no-let': 'error', // let, var 대신 const 사용
    'no-var': 'error', // var 금지
    'prefer-const': 'error', // const 선호
    // 루프 금지
    'functional/no-loop-statements': 'error', // 모든 루프문 금지
    // 데이터 불변성
    'functional/immutable-data': 'warn', // 배열/객체 변이 메서드 경고
    // 파라미터 관련
    'no-param-reassign': ['error', { props: true }] // 파라미터 재할당 금지
  }
}

const unUsedImportsStyles = {
  plugins: {
    'unused-imports': unusedImports
  },
  rules: {
    'no-unused-vars': 'off',
    'unused-imports/no-unused-imports': 'error',
    'unused-imports/no-unused-vars': [
      'error',
      {
        vars: 'all',
        varsIgnorePattern: '^_',
        args: 'after-used',
        argsIgnorePattern: '^_'
      }
    ]
  }
}

const customCodeStyles = {
  plugins: {
    '@typescript-eslint': tseslint.plugin
  },
  rules: {
    'max-depth': ['error', 2],
    'padding-line-between-statements': [
      'error',
      { blankLine: 'always', prev: '*', next: 'return' },
      { blankLine: 'always', prev: '*', next: 'if' },
      { blankLine: 'always', prev: 'function', next: '*' },
      { blankLine: 'always', prev: '*', next: 'function' }
    ],
    'no-restricted-syntax': [
      'error',
      {
        selector: 'TSInterfaceDeclaration',
        message: 'Interface 대신 type 을 사용하세요.'
      },
      {
        selector: 'ConditionalExpression',
        message: '삼항 연산자 대신 if 를 사용하세요.'
      }
    ],
    'no-shadow': 'off', // 기본 ESLint 규칙은 비활성화
    '@typescript-eslint/no-shadow': [
      'error',
      {
        builtinGlobals: true,
        hoist: 'all',
        allow: [] // 예외를 허용하고 싶은 변수 이름들
      }
    ]
  }
}

const eslintConfig = [
  ...compat.extends('next/core-web-vitals', 'next/typescript'),
  globalIgnores([
    '**/*.d.ts',
    '**/*.d.mts',
    '**/*.d.cts',
    'build/**/*',
    'dist/**/*',
    'node_modules/**/*',
    '.next/**/*',
    '.react-router/**/*',
    'eslint.config.mjs',
    'prettier.config.mjs'
  ]),
  functionalStyles,
  unUsedImportsStyles,
  customCodeStyles
]

export default eslintConfig
EOF

elif [ "$IS_REMIX" = "true" ]; then
  echo "  Creating Remix 3 flat config (eslint.config.mjs)..."
  cat > eslint.config.mjs << 'EOF'
import js from '@eslint/js'
import globals from 'globals'
import reactHooks from 'eslint-plugin-react-hooks'
import reactRefresh from 'eslint-plugin-react-refresh'
import tseslint from 'typescript-eslint'
import { globalIgnores } from 'eslint/config'
import functional from 'eslint-plugin-functional'
import unusedImports from 'eslint-plugin-unused-imports'

const customCodeStyles = {
    plugins: {
        '@typescript-eslint': tseslint.plugin
    },
    rules: {
        'max-depth': ['error', 2],
        'padding-line-between-statements': [
            'error',
            { blankLine: 'always', prev: '*', next: 'return' },
            { blankLine: 'always', prev: '*', next: 'if' },
            { blankLine: 'always', prev: 'function', next: '*' },
            { blankLine: 'always', prev: '*', next: 'function' }
        ],
        'no-restricted-syntax': [
            'error',
            {
                selector: 'TSInterfaceDeclaration',
                message: 'Interface 대신 type 을 사용하세요.'
            },
            {
                selector: 'ConditionalExpression',
                message: '삼항 연산자 대신 if 를 사용하세요.'
            }
        ],
        'no-shadow': 'off', // 기본 ESLint 규칙은 비활성화
        '@typescript-eslint/no-shadow': [
            'error',
            {
                builtinGlobals: true,
                hoist: 'all',
                allow: [] // 예외를 허용하고 싶은 변수 이름들
            }
        ]
    }
}

const unUsedImportsStyles = {
    plugins: {
        'unused-imports': unusedImports,
    },
    rules: {
        'no-unused-vars': 'off',
        'unused-imports/no-unused-imports': 'error',
        'unused-imports/no-unused-vars': [
            'error',
            {
                vars: 'all',
                varsIgnorePattern: '^_',
                args: 'after-used',
                argsIgnorePattern: '^_'
            }
        ],
    }
}

const functionalStyles = {
    plugins: {
        functional
    },
    rules: {
        // 변수 선언 관련
        'functional/no-let': 'error', // let, var 대신 const 사용
        'no-var': 'error', // var 금지
        'prefer-const': 'error', // const 선호
        // 루프 금지
        'functional/no-loop-statements': 'error', // 모든 루프문 금지
        // 데이터 불변성
        'functional/immutable-data': 'warn', // 배열/객체 변이 메서드 경고
        // 파라미터 관련
        'no-param-reassign': ['error', { props: true }] // 파라미터 재할당 금지
    }
}

export default tseslint.config([
    globalIgnores([
      '**/*.d.ts',
      '**/*.d.mts',
      '**/*.d.cts',
      'build/**/*',
      'dist/**/*',
      'node_modules/**/*',
      '.next/**/*',
      '.react-router/**/*',
      'eslint.config.mjs',
      'prettier.config.mjs'
    ]),
    {
        files: ['**/*.{ts,tsx}'],
        extends: [
            js.configs.recommended,
            tseslint.configs.recommended,
            reactHooks.configs['recommended-latest'],
            reactRefresh.configs.vite,
        ],
        languageOptions: {
            ecmaVersion: 'latest',
            globals: {
                // 글로벌 설정을 추가
                ...globals.browser,
            },
        },
    },
    functionalStyles,
    unUsedImportsStyles,
    customCodeStyles
])
EOF

else
  echo "  Creating general TypeScript flat config (eslint.config.mjs)..."
  cat > eslint.config.mjs << 'EOF'
import js from '@eslint/js'
import tseslint from 'typescript-eslint'
import { globalIgnores } from 'eslint/config'
import functional from 'eslint-plugin-functional'
import unusedImports from 'eslint-plugin-unused-imports'

const customCodeStyles = {
  plugins: {
    '@typescript-eslint': tseslint.plugin
  },
  rules: {
    'max-depth': ['error', 2],
    'padding-line-between-statements': [
      'error',
      { blankLine: 'always', prev: '*', next: 'return' },
      { blankLine: 'always', prev: '*', next: 'if' },
      { blankLine: 'always', prev: 'function', next: '*' },
      { blankLine: 'always', prev: '*', next: 'function' }
    ],
    'no-restricted-syntax': [
      'error',
      {
        selector: 'TSInterfaceDeclaration',
        message: 'Interface 대신 type 을 사용하세요.'
      },
      {
        selector: 'ConditionalExpression',
        message: '삼항 연산자 대신 if 를 사용하세요.'
      }
    ],
    'no-shadow': 'off', // 기본 ESLint 규칙은 비활성화
    '@typescript-eslint/no-shadow': [
      'error',
      {
        builtinGlobals: true,
        hoist: 'all',
        allow: [] // 예외를 허용하고 싶은 변수 이름들
      }
    ]
  }
}

const functionalStyles = {
  plugins: {
    functional
  },
  rules: {
    'functional/no-let': 'error',
    'no-var': 'error',
    'prefer-const': 'error',
    'functional/no-loop-statements': 'error',
    'functional/immutable-data': 'warn',
    'no-param-reassign': ['error', { props: true }]
  }
}

const unUsedImportsStyles = {
  plugins: {
    'unused-imports': unusedImports
  },
  rules: {
    'no-unused-vars': 'off',
    'unused-imports/no-unused-imports': 'error',
    'unused-imports/no-unused-vars': [
      'error',
      {
        vars: 'all',
        varsIgnorePattern: '^_',
        args: 'after-used',
        argsIgnorePattern: '^_'
      }
    ]
  }
}

export default tseslint.config([
  js.configs.recommended,
  ...tseslint.configs.recommended,
  globalIgnores([
    '**/*.d.ts',
    '**/*.d.mts',
    '**/*.d.cts',
    'build/**/*',
    'dist/**/*',
    'node_modules/**/*',
    '.next/**/*',
    '.react-router/**/*',
    'eslint.config.mjs',
    'prettier.config.mjs'
  ]),
  customCodeStyles,
  functionalStyles,
  unUsedImportsStyles
])
EOF
fi

# package.json scripts 추가 (레시피 기반 커스텀 스크립트)
echo "  Adding optimized lint scripts to package.json..."
if command -v jq &> /dev/null; then
  # 레시피의 최적화된 eslint 명령어 사용
  jq '.scripts.eslint = "eslint --fix --ignore-pattern .gitignore --cache --cache-location ./node_modules/.cache/eslint ."' package.json > package.json.tmp && mv package.json.tmp package.json
else
  echo "  jq not available, please manually add this script to package.json:"
  echo "    \"eslint\": \"eslint --fix --ignore-pattern .gitignore --cache --cache-location ./node_modules/.cache/eslint .\""
fi

echo ""
echo "  ✅ ESLint 설정이 완료되었습니다!"
echo "  레시피 특징:"
echo "    ✨ Flat Config (eslint.config.mjs) 사용"
echo "    ✨ 함수형 프로그래밍 규칙 (eslint-plugin-functional)"
echo "    ✨ 사용하지 않는 import 자동 삭제 (eslint-plugin-unused-imports)"
echo "    ✨ 커스텀 코드 스타일 (interface 금지, 삼항연산자 금지 등)"
echo "    ✨ 캐시 최적화 및 .gitignore 패턴 자동 적용"
echo ""
echo "  사용법:"
echo "    pnpm eslint    # 린트 검사 + 자동 수정 (캐시 사용)"
echo ""
echo "  프로젝트별 설정:"
if [ "$IS_NEXT" = "true" ]; then
  echo "    📦 Next.js 15 + FlatCompat 구성"
elif [ "$IS_REMIX" = "true" ]; then
  echo "    ⚡ Remix 3 + Vite 구성"
else
  echo "    📝 TypeScript 일반 구성"
fi