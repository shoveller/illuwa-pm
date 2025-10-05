#eslint #nextjs #react-router #typescript #설정 #린터 #2025-08-04 
# 코어 레시피
- typescript + eslint 는 [typescript-eslint](https://typescript-eslint.io/) 라는 패키지와 함께 사용해야 정상적으로 동작한다.
	- 아래의 코어 레시피는 직/간접적으로 [typescript-eslint](https://typescript-eslint.io/) 를 설치한 상태로 진행한다.

## next 15
- 프로젝트를 스케폴드할때 설치하면 최신 레시피가 설치된다.
	- 기본으로 설치되는 플러그인 목록은 [이곳](https://nextjs.org/docs/app/api-reference/config/eslint#eslint-plugin)에 있다.
	- 레거시 룰을 flatconfig 에 맞춰 다시 만들지 않고 `FlatCompat` 이라는 컨버터를 사용해서 재활용하는 것이 특징이다.
- 그런데 내가 테스트를 했을 때는 peer dependacy 가 심각하게 빠져 있었다. 버전에 따라 이런 에러는 생길 수도 있지.
```sh
pnpm i -D eslint-plugin-react-hooks @next/eslint-plugin-next zod@latest
```

```js
// eslint.config.mjs
import { dirname } from "path";
import { fileURLToPath } from "url";
import { FlatCompat } from "@eslint/eslintrc";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const compat = new FlatCompat({
  baseDirectory: __dirname,
});

const eslintConfig = [
  ...compat.extends("next/core-web-vitals", "next/typescript"),
];

export default eslintConfig;
```

## remix 3
- 최근까지 설치할 때 자동으로 eslint 설정을 추가해 주었는데 요즘은 아예 생략이 되서 나온다.
	- vite 버전으로 나온 타입스크립트 레시피를 사용하기로 한다. 
```sh
pnpm i -D eslint @eslint/js globals eslint-plugin-react-hooks typescript-eslint zod@latest
```

- 프로젝트 루트에 `eslint.config.mjs` 를 수동으로 추가한다.
```js
// eslint.config.mjs
import js from '@eslint/js'
import globals from 'globals'
import reactHooks from 'eslint-plugin-react-hooks'
import tseslint from 'typescript-eslint'
import { globalIgnores } from 'eslint/config'

export default tseslint.config([
  globalIgnores(['dist']),
  {
    files: ['**/*.{ts,tsx}'],
    extends: [
      js.configs.recommended,
      tseslint.configs.recommended,
      reactHooks.configs['recommended-latest']
    ],
    languageOptions: {
      ecmaVersion: 'latest',
      globals: {
        // 글로벌 설정을 추가
        ...globals.browser,
      },
    },
  },
])
```

# eslint 용 npm script 추가
- eslint 를 실행하면 자동으로 수정하도록 한다.
	- 캐시 위치를 `node_modules` 아래로 옮기고, `.gitignore` 에 적은 내용을 eslint 에서 무시하도록 한다.
	- 이 커맨드를 수시로 실행해서 동작을 확인하자.
```json
{
	"eslint": "eslint --fix --ignore-pattern .gitignore --cache --cache-location ./node_modules/.cache/eslint ."
}
```

# 함수형 코딩 룰 추가
- 부수효과를 최소화하기 위해 [eslint-plugin-functional](https://github.com/eslint-functional/eslint-plugin-functional) 플러그인을 사용한다.
```sh
pnpm i eslint-plugin-functional -D
```
- [공식 문서에는 typescript 사용시  tseslint 와 함께 사용하라고 되어 있지만](https://github.com/eslint-functional/eslint-plugin-functional/blob/main/GETTING_STARTED.md), 이미 코어에 적용이 되어 있으니 생략한다
```js
import functional from 'eslint-plugin-functional'

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
```

## next 15
- 적용하면 아래와 같은 모습이 된다.
```js
import {dirname} from "path";
import {fileURLToPath} from "url";
import {FlatCompat} from "@eslint/eslintrc";
import functional from 'eslint-plugin-functional'

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const compat = new FlatCompat({
  baseDirectory: __dirname,
});

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
		'no-param-reassign': ['error', {props: true}] // 파라미터 재할당 금지
	}
}

const eslintConfig = [
	...compat.extends("next/core-web-vitals", "next/typescript"), 
	functionalStyles
];

export default eslintConfig;
```

## remix 3
- 적용하면 아래와 같은 모습이 된다.
```js
import js from '@eslint/js'
import globals from 'globals'
import reactHooks from 'eslint-plugin-react-hooks'
import tseslint from 'typescript-eslint'
import { globalIgnores } from 'eslint/config'
import functional from 'eslint-plugin-functional'

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
    globalIgnores(['dist']),
    {
        files: ['**/*.{ts,tsx}'],
        extends: [
            js.configs.recommended,
            tseslint.configs.recommended,
            reactHooks.configs['recommended-latest'],
        ],
        languageOptions: {
            ecmaVersion: 'latest',
            globals: {
                // 글로벌 설정을 추가
                ...globals.browser,
            },
        },
    },
    functionalStyles
])
```

# 사용하지 않는 import와 변수를 삭제하는 코딩 룰 추가
- [eslint-plugin-unused-imports](https://github.com/sweepline/eslint-plugin-unused-imports) 를 사용하면 eslint 가 사용하지 않는 import 문과 변수를 삭제한다. 
	- 작지만 품질 향상에 굉장히 큰 영항을 미친다.
```sh
pnpm i eslint-plugin-unused-imports -D
```

```js
import unusedImports from 'eslint-plugin-unused-imports'

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
```

## next 15
- 적용하면 아래와 같은 모습이 된다.
```js
import {dirname} from "path";
import {fileURLToPath} from "url";
import {FlatCompat} from "@eslint/eslintrc";
import functional from 'eslint-plugin-functional'
import unusedImports from 'eslint-plugin-unused-imports'

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const compat = new FlatCompat({
    baseDirectory: __dirname,
});

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
        'no-param-reassign': ['error', {props: true}] // 파라미터 재할당 금지
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

const eslintConfig = [
    ...compat.extends("next/core-web-vitals", "next/typescript"),
    functionalStyles,
    unUsedImportsStyles
];

export default eslintConfig;
```

## remix 3
- 적용하면 아래와 같은 모습이 된다.
```js
import js from '@eslint/js'
import globals from 'globals'
import reactHooks from 'eslint-plugin-react-hooks'
import tseslint from 'typescript-eslint'
import { globalIgnores } from 'eslint/config'
import functional from 'eslint-plugin-functional'
import unusedImports from 'eslint-plugin-unused-imports'

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
    globalIgnores(['dist']),
    {
        files: ['**/*.{ts,tsx}'],
        extends: [
            js.configs.recommended,
            tseslint.configs.recommended,
            reactHooks.configs['recommended-latest'],
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
    unUsedImportsStyles
])
```

# 커스텀 스타일 추가
- 다른 플러그인에는 없는 개인적인 타입스크립트 설정이 섞인 세팅이다.
- typescript-eslint 를 플러그인으로 사용해야 동작한다.
```sh
pnpm i typescript-eslint -D
```

```js
import tseslint from 'typescript-eslint'

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
```

## next 15
- 적용하면 아래와 같은 모습이 된다.
```js
import { dirname } from 'path'
import { fileURLToPath } from 'url'
import { FlatCompat } from '@eslint/eslintrc'
import functional from 'eslint-plugin-functional'
import unusedImports from 'eslint-plugin-unused-imports'
import tseslint from 'typescript-eslint'

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
  functionalStyles,
  unUsedImportsStyles,
  customCodeStyles
]

export default eslintConfig
```

## remix 3
- 적용하면 아래와 같은 모습이 된다.
```js
import js from '@eslint/js'
import globals from 'globals'
import reactHooks from 'eslint-plugin-react-hooks'
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
    globalIgnores(['dist']),
    {
        files: ['**/*.{ts,tsx}'],
        extends: [
            js.configs.recommended,
            tseslint.configs.recommended,
            reactHooks.configs['recommended-latest'],
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
```

# ignore pattern 추가
- 린팅에서 제외할 파일은 계속 늘어날 것이기 때문에 이렇게 추상화를 하면 좋다.
- `globalIgnores()` 함수를 사용하여 패턴을 지정한다.

## next 15
- 적용하면 아래와 같은 모습이 된다.
```js
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
```

## remix 3
- 적용하면 아래와 같은 모습이 된다.
```js
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
```