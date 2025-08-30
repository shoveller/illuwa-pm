#prettier #포매터 #설정 #코드스타일 #메타프레임워크 #2025-08-04

# 1. 프로젝트의 상태 확인
- 포매터로 prettier 최신 버전을 사용한다. 
- 프로젝트 루트의 `package.json` 에 [prettier](https://www.npmjs.com/package/prettier) 가 설치되어 있는지 확인하고 없다면 development dependecy로 설치한다.
```sh
pnpm i -D prettier
```

- 아래의`prettier.config.mjs` 가 기본 설정이다. 없다면 추가한다.
	- prettier 설정에는 한글 주석을 추가한다.
	- 타입 정의를 jsdoc 으로 추가한다.
```javascript
/** @type {import('prettier').Config} */
const config = {
  endOfLine: "lf",
  semi: false,
  singleQuote: true,
  tabWidth: 2,
  trailingComma: "none"
}

export default config;
```

# 2. 추가 플러그인 설치
- 아래의 최신 플러그인을 development dependecy 로 설치한다.
	- [@ianvs/prettier-plugin-sort-imports](https://www.npmjs.com/package/@ianvs/prettier-plugin-sort-imports) 
	-  [prettier-plugin-css-order](https://www.npmjs.com/package/prettier-plugin-css-order) 
	- [prettier-plugin-classnames](https://www.npmjs.com/package/prettier-plugin-classnames) 
```sh
pnpm i -D @ianvs/prettier-plugin-sort-imports prettier-plugin-css-order prettier-plugin-classnames
```

- 아래의`prettier.config.mjs` 를 수동으로 추가한다.
```javascript
/** @type {import('prettier').Config} */
const config = {
	endOfLine: "lf",
	semi: false,
	singleQuote: true,
	tabWidth: 2,
	trailingComma: "none",
	// import sort[s]
	plugins: [
		'@ianvs/prettier-plugin-sort-imports',
		'prettier-plugin-css-order',
		'prettier-plugin-classnames'
	],
	importOrder: [
		'^react',
		'^next',
		'^react-router',
		'',
		'<BUILTIN_MODULES>',
		'<THIRD_PARTY_MODULES>',
		'',
		'.css$',
		'.scss$',
		'^[.]'
	],
	importOrderParserPlugins: ['typescript', 'jsx', 'decorators-legacy']
	// import sort[e]
}

export default config;
```

# 3. npm script 추가
- `package.json` 에 아래의 npm script 를 추가한다.
- `pnpm prettier` 명령어를 실행해서 정상적으로 동작하는지 확인한다.
```json
{
	"prettier": "prettier --write \"**/*.{ts,tsx,cjs,mjs,json,html,css,js,jsx}\" --cache --config prettier.config.mjs"
}
```
