#!/bin/bash

echo "⚙️ TypeScript 설정 중..."

# 기존 설정 파일 백업
if [ -f "tsconfig.json" ]; then
  echo "  Backing up existing tsconfig.json to tsconfig.json.backup"
  cp tsconfig.json tsconfig.json.backup
fi

if [ -f "tsconfig.base.json" ]; then
  echo "  Backing up existing tsconfig.base.json to tsconfig.base.json.backup"
  cp tsconfig.base.json tsconfig.base.json.backup
fi

# 프로젝트 타입 감지
IS_NEXT=$(grep -q "\"next\"" package.json && echo "true" || echo "false")
IS_REMIX=$(grep -q "@remix-run\|react-router" package.json && echo "true" || echo "false")

# tsconfig.base.json 생성
echo "  Creating tsconfig.base.json..."
cat > tsconfig.base.json << 'EOF'
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
EOF

# tsconfig.json 생성 또는 업데이트 (jq로 정밀 제어)
echo "  Creating or updating tsconfig.json..."
if command -v jq &> /dev/null; then
  if [ -f "tsconfig.json" ]; then
    # 기존 tsconfig.json이 있으면 extends만 추가/업데이트하고 tsconfig.base.json 중복 설정 제거
    echo "    기존 tsconfig.json 업데이트 중..."
    jq '. + {"extends": "./tsconfig.base.json"} | del(.compilerOptions.skipLibCheck, .compilerOptions.incremental, .compilerOptions.tsBuildInfoFile, .compilerOptions.noEmit, .compilerOptions.strict, .compilerOptions.noUnusedLocals, .compilerOptions.noUnusedParameters, .compilerOptions.noFallthroughCasesInSwitch, .compilerOptions.noUncheckedSideEffectImports, .compilerOptions.erasableSyntaxOnly)' tsconfig.json > tsconfig.json.tmp && mv tsconfig.json.tmp tsconfig.json
  else
    # 새로운 tsconfig.json 생성
    echo "    새로운 tsconfig.json 생성 중..."
    echo '{"extends": "./tsconfig.base.json"}' | jq . > tsconfig.json
  fi
else
  # jq가 없는 경우 fallback
  echo "    jq not available, creating basic tsconfig.json..."
  cat > tsconfig.json << 'EOF'
{
  "extends": "./tsconfig.base.json"
}
EOF
fi

# package.json scripts 추가
echo "  Adding type check script to package.json..."
if command -v jq &> /dev/null; then
  jq '.scripts["type:check"] = "tsc"' package.json > package.json.tmp && mv package.json.tmp package.json
else
  echo "  jq not available, please manually add this script to package.json:"
  echo "    \"type:check\": \"tsc\""
fi

# cache 디렉토리 생성
mkdir -p ./node_modules/.cache/tsc

echo ""
echo "  ✅ TypeScript 설정이 완료되었습니다!"
echo "  레시피 특징:"
echo "    ✨ 기본 설정(tsconfig.base.json) + 프로젝트별 설정(tsconfig.json) 분리"
echo "    ✨ 컴파일 성능 최적화 (incremental, skipLibCheck, cache)"
echo "    ✨ 엄격한 타입 검사 (strict, noUnusedLocals, noUnusedParameters)"
echo "    ✨ 타입 체크 전용 (noEmit: true)"
echo ""
echo "  사용법:"
echo "    pnpm type:check    # 타입 검사 (캐시 사용)"
echo ""
echo "  프로젝트별 설정:"
if [ "$IS_NEXT" = "true" ]; then
  echo "    📦 Next.js 15 프로젝트 감지됨 (기본 설정 적용)"
elif [ "$IS_REMIX" = "true" ]; then
  echo "    ⚡ Remix 3 프로젝트 감지됨 (기본 설정 적용)"
else
  echo "    📝 TypeScript 일반 프로젝트 (기본 설정 적용)"
fi
echo ""
echo "  📝 필요시 tsconfig.json에서 프로젝트별 설정을 추가하세요:"
echo "    • Next.js: paths, plugins, jsx 등"
echo "    • Remix: include, paths, jsx 등" 
echo "    • 일반: include, exclude, paths 등"
