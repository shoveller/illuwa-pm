# 타입스크립트 코딩 스타일

## 변수는 불변이므로 const 로만 선언한다

#### 나쁜 예
```js
let x = 1
x += 1
let sum = 0
for (let i = 0; i < 5; i++) sum += i
```

#### 좋은 예
```js
const x = 1
const newX = x + 1
const sum = [0, 1, 2, 3, 4].reduce((a, b) => a + b)
```

## 반복문은 배열 메소드로 작성한다

#### 나쁜 예
```js
const users = ['a', 'b']
users.push('c')           // 가장 마지막에 추가
users.unshift('z')      // 가장 앞에 추가
users.pop()               // 마지막 제거
users.shift()             // 첫번째 제거

const doubled = []
for (let i = 0; i < users.length; i++) {
  doubled.push(users[i] + '!')
}

// 중간 요소 조작
users.splice(1, 2, 'x', 'y')
users.reverse()
users.fill('empty', 1, 3)
```

#### 좋은 예
```js
const users = ['a', 'b']

// 추가
const withNewUser = [...users, 'c']
const withPriority = ['z', ...users]

// 제거
const withoutLast = users.slice(0, -1)
const withoutFirst = users.slice(1)

// 변환
const doubled = users.map(user => user + '!')

// 교체
const replaced = [
  ...users.slice(0, 1),
  'x',
  'y',
  ...users.slice(3)
]

// 순서 역전은 불변객체로
const reversed = [...users].reverse()
const cleared = Array(users.length).fill('empty')
```

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
