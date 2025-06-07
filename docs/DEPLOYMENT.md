# Deployment Guide

This guide covers deploying the Solar Price Tracker application using Kamal and Docker.

## Kamal Deployment (Recommended)

### Prerequisites

1. Server with Docker installed
2. GitHub Container Registry access
3. Domain name configured (e.g., solar-prices.boehs.com)

### Environment Setup

Create `.envrc` file with required environment variables:

```bash
export GITHUB_TOKEN="your_github_personal_access_token"
export KAMAL_REGISTRY_PASSWORD="$GITHUB_TOKEN"
```

Load environment variables:
```bash
source .envrc
```

### Configuration

The `config/deploy.yml` file configures:
- GitHub Container Registry for Docker images
- Server IP and SSH configuration
- Environment variables and secrets
- Database and volume mounts

### Initial Deployment

1. Set up the server:
```bash
kamal setup
```

2. Deploy the application:
```bash
kamal deploy
```

### Updates and Maintenance

```bash
# Deploy updates
kamal deploy

# Check application status
kamal app exec 'bin/rails console'

# View logs
kamal app logs

# Database operations
kamal app exec 'bin/rails db:migrate'
```

## Manual Docker Deployment

### Building the Image

```bash
# Build locally
docker build -t solar-price-tracker .

# Tag for registry
docker tag solar-price-tracker ghcr.io/username/solar-price-tracker:latest

# Push to registry
docker push ghcr.io/username/solar-price-tracker:latest
```

### Running the Container

```bash
# Basic container run
docker run -p 3000:3000 \
  -e RAILS_ENV=production \
  -e SECRET_KEY_BASE=your_secret_key \
  solar-price-tracker

# With volume for SQLite database
docker run -p 3000:3000 \
  -v /path/to/data:/rails/storage \
  -e RAILS_ENV=production \
  solar-price-tracker
```

## Production Setup

### Database Initialization

```bash
# Run migrations
bin/rails db:migrate RAILS_ENV=production

# Create initial user
bin/rails console RAILS_ENV=production
User.create!(email_address: "admin@example.com", password: "secure_password")
```

### Security Considerations

- Seeds are automatically skipped in production
- Ensure proper user accounts are created
- XSS protection enabled by default
- Use secure passwords for user accounts
- Configure proper domain and SSL certificates

### Monitoring

- Application logs via `kamal app logs`
- Database queries in Rails console
- Health checks via HTTP endpoints
- Container resource monitoring

## GitHub Actions (Optional)

For automated deployments, you can set up GitHub Actions with:

```yaml
# .github/workflows/deploy.yml
name: Deploy
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Deploy with Kamal
        run: kamal deploy
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Troubleshooting

### Common Issues

1. **Registry Authentication**: Ensure GITHUB_TOKEN has package write permissions
2. **Database Migrations**: Run migrations manually if auto-migration fails
3. **User Creation**: Create admin users via console in production
4. **DNS Configuration**: Verify domain points to server IP
5. **SSL Certificates**: Configure reverse proxy for HTTPS

### Debug Commands

```bash
# Check container status
kamal app details

# Access container shell
kamal app exec bash

# View configuration
kamal config

# Check registry access
docker login ghcr.io -u username -p $GITHUB_TOKEN
```