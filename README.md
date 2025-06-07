# Solar Price Tracker 🌞

[![CI](https://github.com/ericboehs/solar-price-tracker/actions/workflows/ci.yml/badge.svg)](https://github.com/ericboehs/solar-price-tracker/actions/workflows/ci.yml)
[![Ruby](https://img.shields.io/badge/ruby-3.4+-red.svg)](https://ruby-lang.org)
[![Rails](https://img.shields.io/badge/rails-8.0+-red.svg)](https://rubyonrails.org)

A Ruby on Rails 8 application that tracks solar equipment prices by scraping product data, storing historical price information, and providing a responsive web interface with comprehensive dark mode support.

## ✨ Features

- **📊 Price History Tracking**: Automatically tracks and visualizes price changes over time
- **🔍 Smart Product Discovery**: Web scraping with flexible CSS selectors and bundle filtering
- **👀 Watch System**: Monitor specific URLs or products with advanced filtering options
- **📈 Interactive Charts**: Chart.js integration with price trend analysis and mouse snapping
- **🌙 Dark Mode**: Comprehensive dark theme with image dimming and localStorage persistence
- **📱 Responsive Design**: Mobile-first approach with Tailwind CSS
- **🔐 Authentication**: Rails 8 built-in authentication with login-only access
- **🛡️ Security**: XSS protection and safe URL handling
- **🚀 Modern Rails**: Built with Rails 8, Turbo, and Stimulus

## 🛠️ Architecture

### Core Models

- **Product**: Stores product information with slug-based deduplication
  - Price trend analysis and highest/lowest price tracking
  - Relationships with price histories
  
- **PriceHistory**: Tracks price changes over time with validation

- **Watch**: Polymorphic model for monitoring URLs or specific products
  - Advanced filtering with omit lists and bundle exclusion
  - Support for both search URLs and individual product tracking
  - Protected behind authentication

- **User**: Authentication model with secure password handling
  - Email-based login with bcrypt password hashing
  - Session management with proper security measures

### Services

- **ProductScraperService**: Main scraping logic with flexible CSS selectors
  - Bundle detection and filtering
  - Sale price prioritization
  - Slug-based deduplication

## 🚀 Getting Started

### Prerequisites

- Ruby 3.4+
- Rails 8.0+
- SQLite3

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/solar-price-tracker.git
cd solar-price-tracker
```

2. Install dependencies:
```bash
bundle install
```

3. Set up the database:
```bash
rails db:create db:migrate db:seed
```

4. Create a user account (Rails console):
```ruby
rails console
User.create!(email_address: "your@email.com", password: "your_password")
```

5. Start the development server:
```bash
rails server
```

6. Visit `http://localhost:3000` to access the application
   - Products are publicly accessible
   - Login at `/session/new` to access watches functionality

## 📝 Usage

### Basic Operations

- **View Products**: Browse the product grid with price change indicators (public access)
- **Product Details**: Click any product to see detailed price history and charts (public access)
- **Authentication**: Login to access watch management features
- **Create Watches**: Monitor specific URLs for new products or track individual items (requires login)
- **Dark Mode**: Toggle between light and dark themes (persists across sessions)

### Web Scraping

Run the scraper manually in Rails console:
```ruby
ProductScraperService.new.scrape_products
```

### Database Management

```bash
# Reset and reseed database
rails db:drop db:create db:migrate db:seed

# Check migration status
rails db:migrate:status
```

## 🎨 UI Components

- **Product Grid**: Responsive cards with trend indicators and dark mode styling
- **Interactive Charts**: Price visualization with Chart.js and dark mode color detection
- **Watch Management**: CRUD interface for monitoring with advanced filtering
- **Full Screen Modals**: Click product images for full-screen viewing

## 🔧 Configuration

### Environment Variables

The application uses Rails credentials for sensitive configuration. No additional environment variables are required for basic operation.

### Database Schema

The application uses SQLite3 by default. Key tables:
- `products`: Product information with slug indexing
- `price_histories`: Historical price data with timestamp indexing  
- `watches`: Polymorphic watch configuration with filtering options
- `users`: Authentication with bcrypt password hashing
- `sessions`: Session management for user authentication

## 🧪 Testing

The application has comprehensive test coverage with parallel testing support:

- **167 tests** covering all major components
- **97.97% line coverage** (386/394 lines)
- **89.1% branch coverage** (139/156 branches)
- **SimpleCov integration** with parallel test result merging

Run the test suite:
```bash
bin/rails test
```

For system tests:
```bash
bin/rails test:system
```

View coverage report (generated after running tests):
```bash
open coverage/index.html
```

Code quality and style:
```bash
bin/rubocop -A
```

## 📦 Deployment

The application is containerized and ready for deployment:

### Using Kamal (Recommended)

1. Set up your server with Docker and configure `config/deploy.yml`
2. Set environment variables in `.envrc`:
   ```bash
   export GITHUB_TOKEN="your_github_token"
   ```

3. Initial setup:
   ```bash
   kamal setup
   ```

4. Deploy updates:
   ```bash
   kamal deploy
   ```

### Manual Docker Deployment

```bash
# Build Docker image
docker build -t solar-price-tracker .

# Run container
docker run -p 3000:3000 solar-price-tracker
```

### Production Considerations

- Database seeds are automatically skipped in production
- Ensure proper user accounts are created for production access
- XSS protection is enabled by default

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](#license) file for details.

---

## License

MIT License

Copyright (c) 2025 Solar Price Tracker

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

## ⭐ Acknowledgments

- Built with Ruby on Rails 8
- UI powered by Tailwind CSS
- Charts provided by Chart.js
- Web scraping with Nokogiri
- Icons from Heroicons