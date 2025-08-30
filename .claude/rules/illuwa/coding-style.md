# 타입스크립트 코딩 스타일

## 함수는 가능하면 프로토타입이 없는 화살표 함수로 구현한다

#### 나쁜 예
```js
function a() {}
```

#### 좋은 예
```js
const a = () => {}
```

## 변수의 이름은 긍정형으로 쓴다
#### 나쁜 예
```js
if (notFailed) {
    return 1
}
```

#### 좋은 예
```js
if (succeeded) {
    return 1
}
```

## 함수는 중괄호 없이 return 할수 없다.

#### 나쁜 예
```js
if (!a) return
```

#### 좋은 예
```js
if (!a) {
    return
}
```

## 분기처리는 오직 중첩 없는 if 문과 early return만으로 구현한 순수함수로 구현한다

#### 나쁜 예
```js
if (a) {
  if (b) {
    return x
  }
}
```

#### 좋은 예
```js
if (!a) {
    return
}
if (!b) {
    return
}
return x
```

### 중첩 if 문이 필요한 구간은 순수함수로 구현한다

#### 나쁜 예
```js
if (a) {
  if (b) {
    if (c) return x
    return y
  }
  return z
}
```

#### 좋은 예
```js
if (a && b && c) {
    return x
}
if (a && b) {
    return y
}
if (a) {
    return z
}
```

### switch 가 필요한 구간은 순수함수로 구현한다

#### 나쁜 예
```js
switch (type) {
  case 'A': return x
  case 'B': return y
}
```

#### 좋은 예
```js
if (type === 'A') {
    return x
}
if (type === 'B') {
    return y
}
```

### 삼항 연산자가 필요한 구간은 순수함수로 구현한다

#### 나쁜 예
```js
const x = a ? (b ? c : d) : e
```

#### 좋은 예
```js
const getX = () => {
  if (!a) {
    return e
  }
  return b ? c : d
}
const x = getX()
```
