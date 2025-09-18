# next.js 용 추가 레시피

- next.js 는 css 파일의 타이핑을 기본적으로 제공하지 않는다.
  - 아래와 같은 내용의 `src/types/css.d.ts` 를 추가해서 추가 설정을 하지 않게 한다. 
```ts
// src/types/css.d.ts
declare module '*.css' {
  const styles: { [key: string]: string };
  export default styles;
}

declare module '*.scss' {
  const styles: { [key: string]: string };
  export default styles;
}

declare module '*.sass' {
  const styles: { [key: string]: string };
  export default styles;
}

declare module '*.less' {
  const styles: { [key: string]: string };
  export default styles;
}

declare module '*/globals.css' {
  const styles: any;
  export default styles;
}
```