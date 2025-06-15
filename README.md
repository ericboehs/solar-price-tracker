# Solar Price Tracker

A Rails application for tracking prices of solar equipment from various e-commerce sites, starting with SignatureSolar.com. The app monitors product listings, tracks price changes over time, and provides insights into pricing trends.

## Features

- **Automated Price Tracking**: Scrapes product listings and individual product pages
- **Price History**: Maintains complete price history for trend analysis
- **Smart Filtering**: Excludes bundles and unwanted products
- **Watch Lists**: Monitor specific searches or individual products
- **Price Alerts**: Get notified when prices change (planned)
- **Analytics**: View price trends, historical lows, and price change patterns

## Tech Stack

- Ruby on Rails 8.0
- PostgreSQL for data storage
- Nokogiri for web scraping
- Solid Queue for background jobs
- Stimulus for interactive UI components
- SimpleCov for code coverage tracking (95% minimum)

## Setup

1. **Clone the repository**
  ```bash
  git clone https://github.com/ericboehs/solar-price-tracker.git
  cd solar-price-tracker
  ```

2. **Install dependencies**
  ```bash
  bundle install
  ```

3. **Setup database**
  ```bash
  rails db:create
  rails db:migrate
  rails db:seed # Optional: loads sample data
  ```

4. **Configure environment variables**
  ```bash
  cp .env.example .env
  # Edit .env with your configuration
  ```

5. **Start the application**
  ```bash
  bin/dev
  ```

  This starts both the Rails server and Solid Queue for background jobs.

## Usage

### Adding Watches

1. Navigate to the Watches section
2. Click "New Watch"
3. Enter a SignatureSolar.com search URL or product URL
4. Configure filters (exclude bundles, omit specific terms)
5. Save the watch

The system will automatically begin tracking prices for products matching your criteria.

### Viewing Price History

1. Go to the Products page
2. Click on any product to see its details
3. View the price chart showing historical trends
4. Check if the product is at its lowest price

### API Endpoints (Planned)

- `GET /api/products` - List all tracked products
- `GET /api/products/:id/price_history` - Get price history for a product
- `GET /api/watches` - List active watches
- `POST /api/watches` - Create a new watch

## Development

### Running Tests
```bash
rails test
rails test:system
```

### Code Quality
```bash
bin/rubocop
bin/brakeman
```

### Code Coverage

The project uses SimpleCov with a 95% coverage requirement. Coverage reports are generated automatically when running tests:

```bash
rails test
# Coverage report available at coverage/index.html
```

To analyze coverage and get help improving it:
```bash
bin/coverage
```

### Background Jobs

The app uses Solid Queue for background processing. Jobs run automatically when using `bin/dev`.

To run jobs manually:
```bash
rails solid_queue:start
```

### Scraping Schedule

- **Production**: Runs at 2 AM and 12 PM CT daily
- **Development**: Runs every 30 minutes

Configure in `config/recurring.yml`.

## Architecture

### Models

- **Product**: Solar equipment with pricing data
- **PriceHistory**: Historical price records for each product
- **Watch**: Monitors URLs for new products and price changes
- **User**: Authentication and authorization
- **Session**: User session management

### Services

- **ProductScraperService**: Core scraping logic for extracting product data
- **PriceTrackingService**: Manages price history and change detection

### Jobs

- **ScrapeWatchesJob**: Processes all active watches on a schedule
- **ProcessWatchJob**: Scrapes a single watch URL

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes using [Conventional Commits](https://www.conventionalcommits.org/):
  - `feat:` for new features
  - `fix:` for bug fixes
  - `docs:` for documentation changes
  - `style:` for formatting changes
  - `refactor:` for code refactoring
  - `test:` for adding tests
  - `chore:` for maintenance tasks
   
  Example: `git commit -m 'feat: add price alert notifications'`
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the [MIT License](https://opensource.org/licenses/MIT).

## Acknowledgments

- SignatureSolar.com for providing product data
- The Rails community for excellent documentation and gems
