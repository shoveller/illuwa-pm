#!/bin/bash

echo "📋 Makefile 설치 및 설정 중..."

# 기존 Makefile 백업
if [ -f "Makefile" ]; then
  echo "  Backing up existing Makefile to Makefile.backup"
  cp Makefile Makefile.backup
fi

# Makefile 생성
echo "  Creating Makefile with Python development pipeline..."
cat > Makefile << 'EOF'
# Makefile for Python project
# Python 개발 워크플로우 자동화

.PHONY: format lint style type-check test clean install pre-commit dev setup help
.DEFAULT_GOAL := help

# 🎯 메인 format 명령 - 전체 코드 품질 파이프라인
format:
	@echo "🔧 Running ruff check with fixes..."
	uv run ruff check --fix --unsafe-fixes
	@echo "✨ Running ruff format..."
	uv run ruff format
	@echo "🔍 Running mypy type check..."
	uv run mypy .
	@echo "✅ All formatting and checks completed!"

# 🔍 개별 린팅 명령
lint:
	@echo "🔧 Running ruff linting with auto-fixes..."
	uv run ruff check --fix --unsafe-fixes

# ✨ 개별 스타일 포맷팅 명령
style:
	@echo "✨ Running ruff code formatting..."
	uv run ruff format

# 🔍 개별 타입 체크 명령
type-check:
	@echo "🔍 Running mypy type checking..."
	uv run mypy .

# 🧪 테스트 실행
test:
	@echo "🧪 Running tests..."
	uv run pytest

# 🧹 캐시 및 임시 파일 정리
clean:
	@echo "🧹 Cleaning cache and temporary files..."
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".mypy_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".ruff_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -name "*.pyc" -delete 2>/dev/null || true
	@echo "✅ Cleanup completed!"

# 📦 의존성 설치
install:
	@echo "📦 Installing dependencies..."
	uv sync

# 🪝 pre-commit hooks 실행
pre-commit:
	@echo "🪝 Running pre-commit hooks..."
	uv run pre-commit run --all-files

# 🚀 개발 서버 실행 (프로젝트에 따라 조정 필요)
dev:
	@echo "🚀 Starting development server..."
	@if [ -f "main.py" ]; then \
		echo "Detected main.py, starting with python..."; \
		uv run python main.py; \
	elif [ -f "app.py" ]; then \
		echo "Detected app.py, starting with python..."; \
		uv run python app.py; \
	elif [ -f "manage.py" ]; then \
		echo "Detected Django project, starting development server..."; \
		uv run python manage.py runserver; \
	else \
		echo "No main file detected. Please specify your start command."; \
		echo "Available options: main.py, app.py, manage.py"; \
	fi

# 🔧 개발 환경 전체 설정
setup: install
	@echo "🔧 Setting up development environment..."
	uv run pre-commit install
	@echo "✅ Development environment ready!"

# 📋 도움말
help:
	@echo ""
	@echo "🎯 Python Project - Development Commands"
	@echo "========================================"
	@echo ""
	@echo "📝 Code Quality:"
	@echo "  format     - 전체 코드 포맷팅 파이프라인 (lint + style + type-check)"
	@echo "  lint       - Ruff 린팅 (자동 수정 포함)"
	@echo "  style      - Ruff 코드 포맷팅"
	@echo "  type-check - MyPy 타입 검사"
	@echo ""
	@echo "🧪 Testing & Validation:"
	@echo "  test       - 테스트 실행"
	@echo "  pre-commit - Pre-commit hooks 실행"
	@echo ""
	@echo "🔧 Environment:"
	@echo "  install    - 의존성 설치"
	@echo "  setup      - 개발 환경 전체 설정"
	@echo "  clean      - 캐시 및 임시 파일 정리"
	@echo ""
	@echo "🚀 Development:"
	@echo "  dev        - 개발 서버 실행"
	@echo ""
	@echo "💡 Usage: make <command>"
	@echo ""
EOF

echo "  ✅ Makefile 설정이 완료되었습니다!"
echo "  주요 사용법:"
echo "    make format      # 전체 포맷팅 파이프라인"
echo "    make test        # 테스트 실행"
echo "    make setup       # 개발 환경 설정"
echo "    make dev         # 개발 서버 실행"
echo "    make help        # 전체 명령어 도움말"