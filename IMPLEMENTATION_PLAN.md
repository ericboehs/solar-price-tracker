# Solar Price Tracker - Implementation Plan

## Overview
This document outlines the step-by-step implementation plan for building the Solar Price Tracker application from scratch. Each phase builds upon the previous one, ensuring a clean, test-driven development approach with continuous integration.

## Key Principles
- Write tests first or alongside features
- Ensure mobile responsiveness on every view
- Implement dark mode as you build, not as an afterthought
- Commit only when CI passes
- Keep each commit focused on a single feature
- Maintain 95% code coverage throughout

---

## Phase 1: Foundation
**Setup & CI Infrastructure**

### Tasks:
1. **Initialize Rails app and create GitHub repository**
  - Run `BUNDLE_PATH=.bundle rails new solar-price-tracker`
  - Create initial commit
  - Create GitHub repository and push
  - Configure repo

2. **Set up GitHub Actions CI with basic Rails tests**
  - Ensure default Rails tests pass

3. **Add SimpleCov with 95% coverage requirement and GHA summary**
  - Add SimpleCov to Gemfile
  - Configure 95% minimum coverage
  - Set up coverage reporting in GHA summary
  - Make CI fail if coverage drops below 95%

4. **Create CLAUDE.md with CI pass requirement rules**
  - Document that all commits must pass (rails test, rubocop, and brakeman)
  - Include code style guidelines (rubocop-rails-omakase)
  - Add testing requirements
  - Specify dark mode and responsive design requirements

---

## Phase 2: Core Scraping
**Basic Product Data Model**

### Tasks:
5. **Create Product model with migrations and validations**
  - Fields: `title`, `url`, `slug`, `image_url`, `price`, `last_scraped_at`
  - Add unique index on `slug`
  - Validations for required fields
  - Write comprehensive model tests

6. **Implement ProductScraperService with tests**
  - Create service to scrape SignatureSolar.com
  - Parse product listings with Nokogiri
  - Extract title, price, image URL
  - Handle sale prices vs regular prices
  - Implement slug-based deduplication
  - Write thorough service tests

---

## Phase 3: Basic UI
**Viewing Products**

### Tasks:
7. **Add products controller and index view (responsive + dark mode)**
  - Create ProductsController with index action
  - Build responsive grid layout with Tailwind CSS
  - Implement dark mode toggle with localStorage
  - Product cards showing image, title, price
  - Write controller and view tests

8. **Add product show view with basic info**
  - Create show action in controller
  - Two-column layout (mobile stacks)
  - Display full product details
  - Link to original product page
  - Continue dark mode support

9. **Create seeds.rb with sample scraped products (dev only)**
  - Run scraper to populate sample data
  - Only seed in development environment
  - Include variety of products and prices

---

## Phase 4: Price History
**Historical Data & Visualization**

### Tasks:
10. **Create PriceHistory model and migrations**
    - Fields: `product_id`, `price`, `recorded_at`
    - Belongs to Product relationship
    - Index on `product_id` and `recorded_at`
    - Validation tests

11. **Update scraper to create price histories**
    - Modify ProductScraperService
    - Create price history on price changes
    - Use $0.01 threshold for changes
    - Update seeds to include historical data

12. **Add Chart.js and price history chart to product show**
    - Install Chart.js via importmap
    - Create line chart for price history
    - Make chart responsive
    - Dark mode aware colors
    - Show chart only if multiple price points

13. **Add price statistics to products index**
    - Calculate 30-day trend percentages
    - Show up/down indicators
    - Display "LOW!" badge at historical low
    - Add stats dashboard (total products, recent changes)

---

## Phase 5: Watch System
**Monitoring Configuration**

### Tasks:
14. **Create Watch model (polymorphic) with migrations**
    - Fields: `name`, `description`, `url`, `omit_list`, `exclude_bundles`, `active`
    - Polymorphic `watchable` (watchable_type, watchable_id)
    - Validation for required fields
    - Comprehensive model tests

15. **Add watches controller with CRUD actions and views**
    - Full CRUD functionality
    - Form for creating/editing watches
    - Index view with watch listing
    - Show view with watch details
    - Continue responsive/dark mode patterns
    - Write controller and integration tests

---

## Phase 6: Automation
**Background Processing**

### Tasks:
16. **Configure Solid Queue for background jobs**
    - Solid Queue comes pre-installed with Rails 8
    - Run migrations to create queue tables
    - Verify configuration in config/queue.yml
    - Test queue is working properly

17. **Create ScrapeWatchesJob with daily schedule**
    - Create job to process all active watches
    - Call ProductScraperService for each watch
    - Add recurring schedule configuration
    - Set up for 2am daily in production
    - Write job tests

---

## Phase 7: Security
**Access Control**

### Tasks:
18. **Add Rails 8 authentication (User/Session models)**
    - Generate authentication with Rails 8 generator
    - Create User model with email_address/password_digest
    - Create Session model with user_id, user_agent, ip_address
    - Skip password reset functionality
    - Write authentication tests

19. **Protect watches controller with authentication**
    - Add authentication concern to ApplicationController
    - Require authentication for watches controller
    - Keep products controller public
    - Update navigation to show login/logout
    - Test protected routes

20. **Final testing pass to ensure 95% coverage**
    - Run full test suite
    - Check SimpleCov report
    - Add any missing tests
    - Ensure all features work together
    - Verify CI passes

---

## Completion Checklist

Before considering the project complete, ensure:

- [ ] All tests pass with 95%+ coverage
- [ ] CI/CD pipeline is green
- [ ] Dark mode works across all pages
- [ ] Mobile responsive design is consistent
- [ ] CLAUDE.md documentation is comprehensive
- [ ] Seeds provide good sample data
- [ ] Authentication properly protects watches
- [ ] Scraping job runs on schedule
- [ ] Price histories display correctly
- [ ] All user-facing features have tests

---

## Notes

- Each phase should result in 1-3 focused commits
- Run tests locally before pushing
- Use conventional commit messages
- Keep PRs small and focused
- Document any deviations from the plan
