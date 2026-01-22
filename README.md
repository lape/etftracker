# ETFTrack - Track ETF holdings over time

Simple Ruby application to monitor ETF and fund holdings by scraping data from ExtraETF.com and detecting changes over time.

## Overview

ETFTrack scrapes the stock holding composition of ETFs by ISIN and compares them to previously saved values. This is useful for being aware of rebalancing changes and tracking portfolio evolution.

## Features

- Monitors multiple ETFs/funds simultaneously
- Detects changes in holdings composition
- Displays before/after comparisons when changes occur
- Supports both ETFs and other fund types
- Configurable active/inactive status per fund

## Setup

1. Install dependencies:
   ```bash
   bundle install
   ```

2. Create database:
   ```bash
   # For SQLite (default)
   touch etftrack.sqlite3
   
   # For CockroachDB or PostgreSQL
   # Create .env file from .env.template with your DATABASE_URL
   ```

3. Set up database schema (see etfs.sql for structure)

## Usage

```bash
# Run normally (only shows changes)
ruby etftrack.rb

# Show all funds including unchanged ones
ruby etftrack.rb -s
```

## Development

### Code Style

```bash
# Lint code
bundle exec standardrb

# Auto-fix style issues
bundle exec standardrb --fix
```

### Testing

```bash
# Run all tests
ruby -Itest test/test_*.rb

# Run specific test file
ruby -Itest test/test_extraetf_parser.rb
```

## Architecture

### Core Business Logic

The change detection algorithm:

1. **HTML Retrieval**: Fetches the current holdings page for an ETF
2. **Parsing**: Extracts stock names, positions, and percentages
3. **Hashing**: Creates MD5 hash of sorted stock names for comparison
4. **Comparison**: Compares current hash with stored hash
5. **Notification**: Displays changes if detected
6. **Persistence**: Updates database with new hash and holdings

### Data Flow

```
ExtraETF.com → HTTP Request → HTML Parser → Stock List
                                    ↓
                              Hash Generation
                                    ↓
                          Compare with Database
                                    ↓
                        Change? → Display & Save
```

### Project Structure

```
etftrack/
├── etftrack.rb          # Main entry point
├── lib/
│   ├── models/
│   │   └── etf.rb       # ActiveRecord model
│   ├── parsers/
│   │   └── extraetf_parser.rb  # HTML parsing logic
│   ├── utils/
│   │   ├── output_formatter.rb # Terminal output formatting
│   │   └── error_handler.rb    # Error handling
│   └── config/
│       └── database.rb  # Database configuration
└── test/                # Test files

```

### Key Design Decisions

- **Sorted Hash Comparison**: Stock names are sorted before hashing to ignore order changes
- **Full List Storage**: Complete holdings list is stored for historical reference
- **Active Flag**: ETFs can be disabled without deletion
- **Fund Type Support**: Supports both ETFs and other fund types

### Error Handling

1. **Network Errors**: Caught and reported per ETF, continues processing others
2. **Parsing Errors**: Warnings logged, empty results returned
3. **Database Errors**: Fatal errors that exit the application
4. **Missing Environment**: Clear error message and exit

### Performance

- HTTP timeout of 10 seconds prevents hanging
- Batch processing of all active ETFs
- Single database query with indexed ordering
- No N+1 query problems

## Database Schema

The application expects an `etfs` table with the following structure:

- `id`: Primary key
- `name`: ETF/Fund name
- `isin`: International Securities Identification Number
- `last_hash`: MD5 hash of holdings for change detection
- `time`: Last update timestamp
- `stock_list`: Full holdings list
- `active`: Boolean flag to enable/disable monitoring
- `fund_type`: Type of fund (default: 'etf')

## Customization

The data is pulled from ExtraETF.com. The site-specific parsing code is contained in `lib/parsers/extraetf_parser.rb`. If the page structure changes or you want to use another data provider, you can adapt or create a new parser.

## License

See LICENSE file for details.