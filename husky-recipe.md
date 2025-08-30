#husky #git-hooks #eslint #prettier #typescript #자동화 #2025-08-04

# 허스키 설치
- [husky 공식문서](https://typicode.github.io/husky/get-started.html)를 참고해서 pnpm 을 사용해 설치한다.
```sh
pnpm i husky -D
```

- [husky 공식문서](https://typicode.github.io/husky/get-started.html)를 참고해서 초기화한다.
```sh
pnpm husky init
```

# husky 와 eslint , prettier , typescript 통합
- 프로젝트에 `eslint` , `prettier` , `typescript` 가 모두 설치되어 있는지 확인한다.
- `package.json` 에 각각을 실행하는 명령어가 있는지 확인하고, 없다면 추가한다.
	- `eslint` : eslint 명령어에실행에 커스텀 옵션을 추가해서 실행한다.
	- `prettier` : prettier 명령어에실행에 커스텀 옵션을 추가해서 실행한다.
	- `type:check` : 타입스크립트의 타입 체크 명령에 커스텀 옵션을 추가해서 실행한다.
```diff
"eslint": "eslint --fix --ignore-pattern .gitignore --cache --cache-location ./node_modules/.cache/eslint .",
"prettier": "prettier --write \"**/*.{ts,tsx,cjs,mjs,json,html,css,js,jsx}\" --cache --config prettier.config.mjs",
"type:check": "tsc",
```

- 위 명령어를 한번에 실행하기 위해 [npm-run-all]() 패키지를 설치한다.
```sh
pnpm i npm-run-all -D
```

- `package.json` 에 위 명령어를 한번에 실행하는 명령어를 추가한다.
```diff
"format": "run-s type:check prettier eslint"
```

- `.husky/pre-commit` 의 내용을 아래의 코드로 바꾼다.
```sh
pnpm format
```