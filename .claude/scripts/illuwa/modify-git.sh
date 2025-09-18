#!/bin/bash

echo "📝 Git 기본 설정 중..."
echo "=============================="

# .gitignore 파일 생성 또는 패턴 추가
if [ ! -f ".gitignore" ]; then
  echo "📄 .gitignore 파일을 생성합니다"
  cat > .gitignore << 'GITIGNORE_EOF'
.idea/
.lh/
GITIGNORE_EOF
  echo "✅ .gitignore 파일이 생성되었습니다"
else
  echo "📄 기존 .gitignore 파일에 패턴을 추가합니다"

  # .idea/ 패턴 추가 (중복 방지)
  if ! grep -q "^\.idea/$" .gitignore; then
    echo ".idea/" >> .gitignore
    echo "   ➕ .idea/ 패턴 추가됨"
  else
    echo "   ✅ .idea/ 패턴이 이미 존재합니다"
  fi

  # .lh/ 패턴 추가 (중복 방지)
  if ! grep -q "^\.lh/$" .gitignore; then
    echo ".lh/" >> .gitignore
    echo "   ➕ .lh/ 패턴 추가됨"
  else
    echo "   ✅ .lh/ 패턴이 이미 존재합니다"
  fi
fi

echo ""
echo "✅ Git 기본 설정이 완료되었습니다"
