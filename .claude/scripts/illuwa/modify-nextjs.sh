#!/bin/bash

echo "⚛️ Next.js CSS 타입 정의 추가 중..."
echo "======================================"

# src 디렉토리가 없으면 생성
if [ ! -d "src" ]; then
  echo "📁 src 디렉토리 생성 중..."
  mkdir -p src
fi

# types 디렉토리가 없으면 생성
if [ ! -d "src/types" ]; then
  echo "📁 src/types 디렉토리 생성 중..."
  mkdir -p src/types
fi

# CSS 타입 정의 파일 생성
if [ ! -f "src/types/css.d.ts" ]; then
  echo "📝 CSS 타입 정의 파일 생성 중..."
  cat > src/types/css.d.ts << 'EOF'
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
EOF
  echo "✅ CSS 타입 정의 파일이 생성되었습니다: src/types/css.d.ts"
else
  echo "ℹ️ CSS 타입 정의 파일이 이미 존재합니다"
fi

echo ""
echo "✅ Next.js CSS 타입 설정이 완료되었습니다."