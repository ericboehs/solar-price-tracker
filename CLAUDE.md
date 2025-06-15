# Solar Price Tracker - Development Guide

## Project Context

This is a Rails 8.0 application designed to track solar equipment prices from e-commerce sites, starting with SignatureSolar.com. The app monitors product listings, maintains price history, and provides analytics on pricing trends.

## Core Functionality

### Web Scraping System

The primary feature is web scraping of SignatureSolar.com to extract:
- Product listings from search pages
- Individual product details
- Price information (prioritizing sale prices)
- Product metadata (title, image, URL)

### Data Model

Key models and their relationships:

1. **Product** - Represents a solar equipment item
  - Uses URL slug as unique identifier
  - Tracks current and historical prices
  - Provides price trend analytics

2. **PriceHistory** - Records price changes over time
  - Links to Product via foreign key
  - Captures price at specific timestamps
  - Enables trend analysis

3. **Watch** - Monitors URLs for new products/price changes
  - Polymorphic design (can watch various resources)
  - Supports search URLs and individual products
  - Includes filtering capabilities (omit terms, exclude bundles)

### Background Processing

Uses Solid Queue for job processing:
- **ScrapeWatchesJob** - Processes all active watches
- **ProcessWatchJob** - Scrapes individual watch URLs
- Scheduled via `config/recurring.yml`

## Development Guidelines

### Code Style

- Follow Rails conventions for file organization
- Use service objects for complex business logic
- Keep controllers thin, models focused
- Write descriptive method names

### Commit Messages

This project follows [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Types:**
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation only changes
- `style:` Code style changes (formatting, missing semi-colons, etc)
- `refactor:` Code change that neither fixes a bug nor adds a feature
- `perf:` Performance improvements
- `test:` Adding missing tests or correcting existing tests
- `build:` Changes that affect the build system or external dependencies
- `ci:` Changes to CI configuration files and scripts
- `chore:` Other changes that don't modify src or test files

**Examples:**
```bash
git commit -m "feat: add price drop email notifications"
git commit -m "fix: handle empty product titles in scraper"
git commit -m "docs: update API endpoint documentation"
git commit -m "refactor: extract price parsing logic to service"
```

### Testing

Run tests with:
```bash
rails test
rails test:system
```

### Code Coverage

The project enforces comprehensive test coverage using SimpleCov:
- **Minimum coverage**: 95% overall
- **Per-file minimum**: 80%
- **Branch coverage**: Enabled
- **Coverage reports**: Generated in `coverage/` directory
- **CI integration**: Coverage reports uploaded as artifacts

Coverage configuration in `.simplecov`:
- Excludes test files, config, vendor, and database files
- Groups results by component type (Controllers, Models, Services, etc.)
- Fails CI if coverage drops below thresholds

### Linting & Quality Checks

Check code quality:
```bash
bin/rubocop      # Ruby style guide compliance
bin/brakeman     # Security vulnerability scanning
rails test       # Runs tests with coverage report
```

### Database

Using PostgreSQL for:
- JSON column support
- Full-text search capabilities
- Robust indexing

### Scraping Best Practices

1. **Respect robots.txt** - Check site policies
2. **Rate limiting** - Avoid overwhelming servers
3. **Error handling** - Gracefully handle failed requests
4. **Data validation** - Ensure scraped data is valid
5. **Flexible selectors** - Use fallbacks for CSS selectors

### Security Considerations

- Sanitize scraped content before storage
- Use parameterized queries
- Implement authentication for admin features
- Secure API endpoints

## Key Implementation Details

### ProductScraperService

Core service for web scraping:
- Uses Nokogiri for HTML parsing
- Implements flexible CSS selectors with fallbacks
- Handles price extraction (sale vs regular)
- Filters bundles and unwanted products
- Manages deduplication via URL slugs

### Price Tracking

- Records changes when price differs by > $0.01
- Maintains complete history
- Calculates trends over time periods
- Identifies historical lows

### URL Processing

- Extracts slugs from product URLs for unique identification
- Handles both search result pages and individual product pages
- Supports pagination for large result sets

## Future Enhancements

1. **Multiple Site Support** - Extend beyond SignatureSolar.com
2. **Price Alerts** - Email/SMS notifications
3. **API Development** - RESTful API for external access
4. **Advanced Analytics** - Price predictions, seasonal trends
5. **User Dashboard** - Personalized watchlists and alerts

## Common Tasks

### Adding a New Scraping Target

1. Create a new service class in `app/services/`
2. Implement product extraction logic
3. Update ProductScraperService to handle new site
4. Add site-specific CSS selectors
5. Test thoroughly with various product types

### Debugging Scraping Issues

1. Check page HTML structure for changes
2. Verify CSS selectors in browser console
3. Test with `rails console` using service directly
4. Review logs for error patterns
5. Update selectors as needed

### Performance Optimization

1. Use database indexes effectively
2. Implement caching for frequently accessed data
3. Optimize N+1 queries
4. Consider pagination for large datasets
5. Use bulk inserts for price history

## Environment Setup

### Required Environment Variables

- `DATABASE_URL` - PostgreSQL connection string
- `RAILS_MASTER_KEY` - For credentials encryption
- `SOLID_QUEUE_ASYNC` - Enable async job processing

### Development Tools

- `bin/dev` - Starts Rails server + Solid Queue
- `rails console` - Interactive Ruby session
- `rails db` - Direct database access
- `rails routes` - View all application routes

## Deployment

### Production Considerations

1. Configure recurring jobs in `config/recurring.yml`
2. Set up error monitoring (Rollbar, Sentry)
3. Configure log rotation
4. Implement request caching
5. Monitor scraping success rates

### Scaling

- Use multiple queue workers for parallel processing
- Implement database connection pooling
- Consider CDN for static assets
- Monitor memory usage of scraping jobs
