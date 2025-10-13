#!/usr/bin/env bash

set -euo pipefail

# 기본값 설정
GRAPH_VAR="graph"
OUTPUT_FILE="langgraph.json"
INPUT_FILE=""
ENV_FILE="./.env"

# 도움말 출력
show_help() {
    cat << EOF
Usage: $(basename "$0") <input_file> [OPTIONS]

LangGraph 코드를 분석하여 langgraph.json 설정 파일을 생성합니다.

Arguments:
    input_file              LangGraph 소스 파일 (.py, .js, .ts)

Options:
    --var <variable_name>   그래프 변수명 (기본값: graph)
    --output <file>         출력 파일 경로 (기본값: langgraph.json)
    --env <file>            환경변수 파일 경로 (기본값: ./.env)
    -h, --help              이 도움말 표시

Examples:
    $(basename "$0") prompt-chainning.py
    $(basename "$0") prompt-chainning.py --var my_graph
    $(basename "$0") my-agent.py --var agent --env .env.local
EOF
}

# 인자 파싱
if [[ $# -eq 0 ]]; then
    show_help
    exit 1
fi

# help 옵션 먼저 체크
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

INPUT_FILE="$1"
shift

while [[ $# -gt 0 ]]; do
    case $1 in
        --var)
            GRAPH_VAR="$2"
            shift 2
            ;;
        --output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        --env)
            ENV_FILE="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Error: Unknown option $1"
            show_help
            exit 1
            ;;
    esac
done

# 파일 존재 확인
if [[ ! -f "$INPUT_FILE" ]]; then
    echo "Error: File not found: $INPUT_FILE" >&2
    exit 1
fi

# 파일 확장자 확인
EXTENSION="${INPUT_FILE##*.}"
if [[ ! "$EXTENSION" =~ ^(py|js|ts)$ ]]; then
    echo "Error: Unsupported file extension: $EXTENSION" >&2
    echo "Supported extensions: .py, .js, .ts" >&2
    exit 1
fi

# 그래프 이름 추출 (파일명에서 확장자 제거)
GRAPH_NAME="${INPUT_FILE##*/}"
GRAPH_NAME="${GRAPH_NAME%.*}"

# langgraph.json 생성
cat > "$OUTPUT_FILE" << EOF
{
  "dependencies": [
    "./$INPUT_FILE"
  ],
  "env": "$ENV_FILE",
  "graphs": {
    "$GRAPH_NAME": "./$INPUT_FILE:$GRAPH_VAR"
  }
}
EOF

echo "✓ Generated: $OUTPUT_FILE"
