# Authentication Guide

This guide covers the Rails 8 authentication system implemented in the Solar Price Tracker.

## Overview

The application uses Rails 8's built-in authentication with the following features:
- Email-based login (no signup functionality)
- Secure session management with bcrypt
- Controller-level access protection
- Public access to products, protected access to watches

## User Management

### Creating Users

Users must be created via Rails console (no public signup):

```ruby
# Development/Production console
User.create!(
  email_address: "user@example.com",
  password: "secure_password"
)
```

### User Model

The User model (`app/models/user.rb`) includes:
- `has_secure_password` for bcrypt password hashing
- Email normalization (strip and downcase)
- Association with sessions

## Session Management

### Session Model

Sessions track active user logins with:
- User reference
- User agent (browser/device info)
- IP address
- Automatic timestamps

### Session Controller

Login/logout functionality at `/session/new`:
- Email and password authentication
- Secure cookie-based session storage
- Redirect handling for protected routes

## Access Control

### Controller Protection

```ruby
# Protected controller (watches)
class WatchesController < ApplicationController
  before_action :require_authentication
end

# Public controller (products)
class ProductsController < ApplicationController
  allow_unauthenticated_access
end
```

### Navigation

The header navigation conditionally shows:
- Login/logout links based on authentication status
- Watches menu only for authenticated users
- Public access to products for all users

## Testing

### Test Helpers

Authentication helpers in `test/test_helper.rb`:

```ruby
def sign_in(user)
  post session_url, params: { 
    email_address: user.email_address, 
    password: "password123" 
  }
end
```

### Test Fixtures

User and session fixtures for testing in `test/fixtures/`:
- `users.yml` - Test user accounts with bcrypt passwords
- `sessions.yml` - Active sessions for testing

## Security Features

- Bcrypt password hashing
- Secure session cookies
- XSS protection with safe URL helpers
- IP address and user agent tracking
- Automatic session cleanup on logout

## Deployment Considerations

- Ensure user accounts are created in production console
- Session secrets managed via Rails credentials
- Database migration includes users and sessions tables