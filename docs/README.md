# Documentation Index

This directory contains detailed documentation for the Solar Price Tracker application.

## Available Guides

### 📋 [AUTHENTICATION.md](AUTHENTICATION.md)
Comprehensive guide to the Rails 8 authentication system:
- User management and creation
- Session handling and security
- Access control patterns
- Testing authentication flows

### 🚀 [DEPLOYMENT.md](DEPLOYMENT.md)
Complete deployment guide covering:
- Kamal deployment setup and configuration
- Docker containerization
- Production environment setup
- Security considerations and monitoring

## Quick References

### Main Documentation
- **[README.md](../README.md)** - Project overview and getting started
- **[CLAUDE.md](../CLAUDE.md)** - Technical documentation for development

### Key Development Commands

```bash
# Development
rails server
rails console
bin/rails test

# Code Quality
bin/rubocop -A
bin/brakeman

# Database
rails db:migrate
rails db:seed

# Deployment
kamal deploy
kamal app logs
```

### Architecture Summary

- **Models**: Product, PriceHistory, Watch, User, Session
- **Controllers**: Products (public), Watches (protected), Sessions (auth)
- **Services**: ProductScraperService for web scraping
- **Features**: Price tracking, watch system, dark mode, authentication

## Getting Help

For specific technical questions, refer to:
1. The relevant guide in this docs/ directory
2. CLAUDE.md for development patterns
3. Code comments and tests for implementation details

## Contributing to Documentation

When adding new features:
1. Update relevant guides in docs/
2. Update CLAUDE.md for technical details
3. Update README.md for user-facing changes
4. Ensure examples and commands are tested