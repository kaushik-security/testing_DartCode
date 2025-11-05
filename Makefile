# Makefile for Dart Scan Project

.PHONY: help install deps get analyze format test test-coverage clean build run example lint security-scan doc

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: ## Install dependencies
	@echo "Installing dependencies..."
	dart pub get

deps: install ## Alias for install

get: install ## Alias for install

analyze: ## Run static analysis
	@echo "Running static analysis..."
	dart analyze

format: ## Format code
	@echo "Formatting code..."
	dart format .

test: ## Run tests
	@echo "Running tests..."
	dart test

test-coverage: ## Run tests with coverage
	@echo "Running tests with coverage..."
	dart test --coverage=coverage
	dart run coverage:format_coverage --lcov --in=coverage --out=coverage.lcov --report-on=lib

test-watch: ## Run tests in watch mode
	@echo "Running tests in watch mode..."
	dart test --watch

clean: ## Clean build artifacts
	@echo "Cleaning build artifacts..."
	dart pub run build_runner clean
	rm -rf .dart_tool/build
	rm -rf build
	rm -rf coverage
	rm -rf coverage.lcov

build: ## Build the project
	@echo "Building project..."
	dart pub run build_runner build

run: ## Run the example
	@echo "Running example..."
	dart run example/main.dart

example: run ## Alias for run

lint: ## Run linter
	@echo "Running linter..."
	dart analyze --lints

security-scan: ## Run security scanning (requires Snyk)
	@echo "Running security scan..."
	@if command -v snyk >/dev/null 2>&1; then \
		snyk test --json --file=pubspec.yaml > snyk-report.json; \
		snyk code test; \
		echo "Security scan completed. Check snyk-report.json"; \
	else \
		echo "Snyk not installed. Install with: npm install -g snyk"; \
	fi

doc: ## Generate documentation
	@echo "Generating documentation..."
	@if command -v dartdoc >/dev/null 2>&1; then \
		dartdoc; \
		echo "Documentation generated in doc/api/"; \
	else \
		echo "dartdoc not available. Run: dart pub global activate dartdoc"; \
	fi

deps-check: ## Check for outdated dependencies
	@echo "Checking for outdated dependencies..."
	dart pub outdated

deps-update: ## Update dependencies
	@echo "Updating dependencies..."
	dart pub upgrade

validate: analyze format test ## Run full validation (analyze, format, test)

ci: install analyze test ## CI pipeline (install, analyze, test)

all: clean install analyze format test ## Run full build pipeline

# Development setup
setup: ## Initial project setup
	@echo "Setting up project..."
	dart pub get
	dart run build_runner build
	@echo "Setup complete. Run 'make help' for available commands."

# Docker support (if needed)
docker-build: ## Build Docker image
	@echo "Building Docker image..."
	docker build -t dart-scan-project .

docker-run: ## Run in Docker container
	@echo "Running in Docker container..."
	docker run -it dart-scan-project

# Git hooks setup
hooks: ## Setup git hooks
	@echo "Setting up git hooks..."
	@if command -v pre-commit >/dev/null 2>&1; then \
		pre-commit install; \
		echo "Git hooks installed"; \
	else \
		echo "pre-commit not installed. Install with: pip install pre-commit"; \
	fi

# Release tasks
version-patch: ## Bump patch version
	@echo "Bumping patch version..."
	dart pub run cider version patch

version-minor: ## Bump minor version
	@echo "Bumping minor version..."
	dart pub run cider version minor

version-major: ## Bump major version
	@echo "Bumping major version..."
	dart pub run cider version major

# Cleanup tasks
clean-all: clean ## Clean everything including dependencies
	@echo "Cleaning everything..."
	rm -rf .dart_tool
	rm -rf pubspec.lock
	dart pub cache clean

# Quick development commands
dev: ## Quick development setup
	@echo "Quick development setup..."
	dart pub get
	dart format .
	dart analyze

# Health check
health: ## Check project health
	@echo "=== Project Health Check ==="
	@echo "Dart version: $$(dart --version)"
	@echo "Dependencies: $$(dart pub list --json | jq '.packages | length') packages"
	@echo "Code issues: $$(dart analyze 2>&1 | grep -c 'error\|warning' || echo '0')"
	@echo "Test files: $$(find test -name "*_test.dart" | wc -l)"
	@echo "Library files: $$(find lib -name "*.dart" | wc -l)"
	@echo "Total lines: $$(find lib test -name "*.dart" -exec wc -l {} \; | awk '{sum += $$1} END {print sum}')"
	@echo "Health check complete."
