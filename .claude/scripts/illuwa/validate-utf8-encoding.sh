#!/bin/bash

# UTF-8 인코딩 검증 및 자동 수정 스크립트
# Claude Code PostToolUse 훅에서 호출됨

FILE_PATH="$1"

if [ -z "$FILE_PATH" ]; then
  echo "❌ 파일 경로가 제공되지 않았습니다"
  exit 1
fi

if [ ! -f "$FILE_PATH" ]; then
  echo "❌ 파일이 존재하지 않습니다: $FILE_PATH"
  exit 1
fi

echo "🔍 UTF-8 인코딩 검증 중: $FILE_PATH"

# 현재 파일 인코딩 확인
CURRENT_ENCODING=$(file -I "$FILE_PATH" | cut -d'=' -f2 | tr -d ' ')

if [ "$CURRENT_ENCODING" = "utf-8" ]; then
  echo "✅ UTF-8 인코딩이 올바르게 설정되었습니다"
  
  # 한글/이모지 내용 검증
  if grep -q '[가-힣🔍📝✅❌🎨⚛️📦🐍🚀📁📄➕ℹ️]' "$FILE_PATH" 2>/dev/null; then
    echo "🔤 한글/이모지 콘텐츠 표시 테스트 중..."
    if head -n 3 "$FILE_PATH" | grep -q '[가-힣🔍📝✅❌🎨⚛️📦🐍🚀📁📄➕ℹ️]' 2>/dev/null; then
      echo "✅ 한글/이모지가 올바르게 표시됩니다"
    else
      echo "⚠️ 한글/이모지 표시에 문제가 있을 수 있습니다"
    fi
  fi
  
  exit 0
fi

echo "❌ UTF-8이 아닌 인코딩 감지: $CURRENT_ENCODING"
echo "🔧 UTF-8로 변환 중..."

# 백업 생성
cp "$FILE_PATH" "$FILE_PATH.backup"

# UTF-8로 변환 시도
if iconv -f "$CURRENT_ENCODING" -t UTF-8 "$FILE_PATH.backup" > "$FILE_PATH.tmp" 2>/dev/null; then
  mv "$FILE_PATH.tmp" "$FILE_PATH"
  echo "✅ UTF-8로 변환 완료"
  rm "$FILE_PATH.backup"
else
  echo "❌ 변환 실패, 원본 복구 중..."
  mv "$FILE_PATH.backup" "$FILE_PATH"
  exit 1
fi

# 변환 후 재검증
NEW_ENCODING=$(file -I "$FILE_PATH" | cut -d'=' -f2 | tr -d ' ')
if [ "$NEW_ENCODING" = "utf-8" ]; then
  echo "✅ UTF-8 변환이 성공적으로 완료되었습니다"
else
  echo "❌ 변환 후에도 UTF-8이 아닙니다: $NEW_ENCODING"
  exit 1
fi
