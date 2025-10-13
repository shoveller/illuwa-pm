---
name: add-langgraph-config
description: LangGraph 파일로부터 langgraph.json 설정 파일 자동 생성
---

# LangGraph 설정 파일 생성

사용자가 제공한 LangGraph 소스 파일(.py, .js, .ts)을 분석하여 `langgraph.json` 설정 파일을 자동으로 생성합니다.

## 실행 단계

1. 사용자로부터 필수 인자와 선택 옵션을 받습니다:
   - **필수**: 소스 파일 경로
   - **선택**: `--var <변수명>` (기본값: graph)
   - **선택**: `--env <환경변수파일>` (기본값: ./.env)
   - **선택**: `--output <출력파일>` (기본값: langgraph.json)

2. `.claude/scripts/illuwa/add-langgraph-config.sh` 스크립트를 호출합니다.

3. 생성된 `langgraph.json` 파일을 확인하고 사용자에게 결과를 알립니다.

## 사용법

```bash
# 기본 사용 (파일명만 지정)
/illuwa:add-langgraph-config prompt-chainning.py

# 커스텀 변수명
/illuwa:add-langgraph-config my-agent.py --var workflow

# 모든 옵션 지정
/illuwa:add-langgraph-config my-agent.py --var agent --env .env.prod --output config.json
```

## 동작 방식

1. **소스 파일 분석**: LangGraph 코드에서 그래프 변수 추출
2. **설정 파일 생성**: `langgraph.json` 생성
3. **자동 구성**: dependencies, env, graphs 자동 설정

## 생성되는 파일 형식

```json
{
  "dependencies": [
    "./prompt-chainning.py"
  ],
  "env": "./.env",
  "graphs": {
    "prompt-chainning": "./prompt-chainning.py:graph"
  }
}
```

## 옵션

### 그래프 변수명 지정

```bash
/illuwa:add-langgraph-config my-agent.py --var my_graph
```

기본값은 `graph`이지만, 다른 변수명을 사용하는 경우 `--var` 옵션으로 지정할 수 있습니다.

### 환경변수 파일 지정

```bash
/illuwa:add-langgraph-config my-agent.py --env .env.local
```

기본값은 `./.env`이지만, 다른 환경변수 파일을 사용하는 경우 `--env` 옵션으로 지정할 수 있습니다.

### 출력 파일명 지정

```bash
/illuwa:add-langgraph-config my-agent.py --output config.json
```

기본값은 `langgraph.json`이지만, 다른 파일명으로 생성하려면 `--output` 옵션을 사용합니다.

### 모든 옵션 조합

```bash
/illuwa:add-langgraph-config my-agent.py --var agent --env .env.prod --output custom.json
```

## 지원 파일 형식

- **Python**: `.py`
- **JavaScript**: `.js`
- **TypeScript**: `.ts`

## 실행 예시

### 예시 1: 기본 사용

```bash
/illuwa:add-langgraph-config prompt-chainning.py

✓ Generated: langgraph.json
```

### 예시 2: 커스텀 그래프 변수

```bash
/illuwa:add-langgraph-config my-agent.py --var workflow

✓ Generated: langgraph.json
```

생성된 파일:
```json
{
  "dependencies": [
    "./my-agent.py"
  ],
  "env": "./.env",
  "graphs": {
    "my-agent": "./my-agent.py:workflow"
  }
}
```

### 예시 3: 프로덕션 환경 설정

```bash
/illuwa:add-langgraph-config production-agent.py --var agent --env .env.production

✓ Generated: langgraph.json
```

생성된 파일:
```json
{
  "dependencies": [
    "./production-agent.py"
  ],
  "env": ".env.production",
  "graphs": {
    "production-agent": "./production-agent.py:agent"
  }
}
```

## 에러 처리

### 파일을 찾을 수 없는 경우

```
Error: File not found: my-agent.py
```

→ 파일 경로를 확인하거나 올바른 파일명을 입력하세요.

### 지원하지 않는 파일 형식

```
Error: Unsupported file extension: .txt
Supported extensions: .py, .js, .ts
```

→ Python, JavaScript, TypeScript 파일만 지원합니다.

## 장점

- **빠른 설정**: 수동으로 JSON 작성할 필요 없음
- **오타 방지**: 자동 생성으로 설정 오류 최소화
- **일관성 유지**: 표준 LangGraph 설정 포맷 준수
- **시간 절약**: 매번 동일한 구조를 작성하는 시간 절약

## 참고

- 이 커맨드는 `.claude/scripts/illuwa/add-langgraph-config.sh`를 호출합니다
- 생성된 `langgraph.json`은 LangGraph CLI에서 바로 사용할 수 있습니다
- 기존 `langgraph.json` 파일이 있는 경우 덮어씁니다

## 관련 커맨드

- LangGraph 공식 문서: https://langchain-ai.github.io/langgraph/
