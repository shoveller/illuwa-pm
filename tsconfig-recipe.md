#nextjs #react-router #typescript #tsconfig #설정 #메타프레임워크 #2025-08-04 

- `tsc` 는 컴파일러의 기능과 타입 체커의 기능을 모두 가지고 있다.
	- `tsc` 는 컴파일 속도가 느리다. 2025년 현 시점에서의 최신 레시피는 tsc 를 타입 체커로만 사용하는 것이다.
	- 타입스크립트 최신판에서는 tsc 를 go 언어로 다시 만든다고 하니 그때는 tsc 만으로 컴파일과 타입 체크를 동시에 할지도 모르겠다.
- 아래의 `tsconfig.base.json` 을 프로젝트 루트에 배치하고 사용하면 보일러플레이트 코드를 최소화할 수 있다.
```json
{
  "compilerOptions": {
    /* 컴파일 성능 최적화 */
    "skipLibCheck": true, // 라이브러리 타입 정의 파일 검사 건너뛰기 (빌드 속도 향상)
    "incremental": true, // 증분 컴파일 활성화 (이전 빌드 정보 재사용)
    "tsBuildInfoFile": "./node_modules/.cache/tsc/tsbuildinfo", // 증분 컴파일 정보 저장 위치

    /* 출력 제어 */
    "noEmit": true, // JavaScript 파일 생성하지 않음 (타입 검사만 수행)

    /* 엄격한 타입 검사 */
    "strict": true, // 모든 엄격한 타입 검사 옵션 활성화
    "noUnusedLocals": true, // 사용하지 않는 지역 변수 에러 처리
    "noUnusedParameters": true, // 사용하지 않는 함수 매개변수 에러 처리
    "noFallthroughCasesInSwitch": true, // switch문에서 break 누락 시 에러 처리
    "noUncheckedSideEffectImports": true, // 부작용이 있는 import 구문의 타입 검사 강화

    /* 구문 분석 최적화 */
    "erasableSyntaxOnly": true // TypeScript 고유 구문만 제거하고 JavaScript 호환성 유지
  }
}
```

## next 15
- 2025. 08.05 버전은 이렇다.
```json
{
  "extends": "./tsconfig.base.json",
  "compilerOptions": {
    "target": "ES2017",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "plugins": [
      {
        "name": "next"
      }
    ],
    "paths": {
      "@/*": ["./src/*"]
    },
    "types": ["node"]
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
```

## remix 3
- 2025. 08.05 버전은 이렇다.
```json
{
  "extends": "./tsconfig.base.json",
  "include": [
    "**/*",
    "**/.server/**/*",
    "**/.client/**/*",
    ".react-router/types/**/*"
  ],
  "compilerOptions": {
    "lib": ["DOM", "DOM.Iterable", "ES2022"],
    "types": ["node", "vite/client"],
    "target": "ES2022",
    "module": "ES2022",
    "moduleResolution": "bundler",
    "jsx": "react-jsx",
    "rootDirs": [".", "./.react-router/types"],
    "baseUrl": ".",
    "paths": {
      "~/*": ["./app/*"]
    },
    "esModuleInterop": true,
    "verbatimModuleSyntax": true,
    "resolveJsonModule": true
  }
}
```

## npm script 추가
- 타입 체크용 스크립트는 휴대하는게 좋다.
```json
{
	"type:check": "tsc",
}
```