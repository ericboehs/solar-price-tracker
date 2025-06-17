# Solar Price Tracker - Utility Scripts

This directory contains various utility scripts for development, CI/CD, and external integrations.

## 🔧 Development Tools

### `bin/ci`
**Comprehensive CI pipeline runner**

Runs the complete continuous integration pipeline including linting, security checks, and tests.

```bash
# Run full CI pipeline
bin/ci

# Auto-fix issues and run CI
bin/ci --fix
```

**What it does:**
- **File formatting**: Uses `eclint` to check/fix file formatting (line endings, whitespace, etc.)
- **Code style**: Runs `rubocop` for Ruby style guide compliance
- **Security scanning**: Uses `brakeman` to check for security vulnerabilities
- **Testing**: Runs both unit tests (`rails test`) and system tests (`rails test:system`)

**CI Integration:**
- Used in pre-commit hooks to ensure code quality
- Sends macOS notifications on success/failure (requires `terminal-notifier`)
- Returns appropriate exit codes for CI systems

### `bin/coverage`
**Code coverage analysis and reporting**

Analyzes test coverage and provides improvement suggestions.

```bash
# Analyze coverage after running tests
bin/coverage
```

**Features:**
- **Minimum coverage**: 95% overall, 80% per file
- **Branch coverage**: Enabled for thorough analysis
- **Coverage reports**: Generated in `coverage/` directory
- **Grouping**: Results grouped by component type (Controllers, Models, Services, etc.)
- **CI artifacts**: Coverage reports uploaded as CI artifacts
- **Improvement suggestions**: Identifies files needing better coverage

**Coverage Requirements:**
- Overall coverage must be ≥ 95%
- Individual files must be ≥ 80% covered
- Branch coverage is tracked and reported
- CI fails if coverage drops below thresholds

### `bin/rubocop`
**Ruby code style checker**

```bash
# Check code style
bin/rubocop

# Auto-fix violations
bin/rubocop -A
```

### `bin/brakeman`
**Security vulnerability scanner**

```bash
# Run security scan
bin/brakeman
```

## 🚀 Other Development Scripts

### `bin/dev`
Start the development server with all necessary services (Rails + Solid Queue).

### `bin/setup`
Set up the application for the first time (dependencies, database, etc.).

### `bin/jobs`
Manage background job processing with Solid Queue.

### `bin/watch-ci`
Continuously watch for file changes and run CI checks.

## 📋 Quality Standards

All scripts in this directory maintain the following standards:

- **Error Handling**: Proper exit codes and error messages
- **Documentation**: Clear help text and examples
- **Logging**: Informative output with emoji indicators
- **Integration**: Works seamlessly with project's CI/CD pipeline
- **Security**: No credentials committed to repository
- **Performance**: Efficient execution with appropriate timeouts

## 🔗 Related Documentation

- [Main README](../README.md) - Project overview and setup
- [CLAUDE.md](../CLAUDE.md) - Development guidelines and conventions
- [Conventional Commits](https://www.conventionalcommits.org/) - Commit message format

## 🤝 Contributing

When adding new scripts to this directory:

1. Make them executable: `chmod +x bin/script-name`
2. Add comprehensive help text
3. Follow existing patterns for error handling and output
4. Update this README with documentation
5. Test with the CI pipeline (`bin/ci`)
6. Ensure proper test coverage (`bin/coverage`)
