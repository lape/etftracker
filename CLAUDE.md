# ETFTrack Project Guide

Tracks ETF and fund holdings.

## Important Instructions
- Always read and update ROADMAP.md

## Commands
- Run app: `ruby etftrack.rb`
- Run with showing all funds: `ruby etftrack.rb -s`
- Lint: `bundle exec standardrb`
- Fix lint issues: `bundle exec standardrb --fix`
- Setup: `bundle install`
- Create SQLite DB: `touch etftrack.sqlite3`

## Code Style
- Follow Standard Ruby style guide (project uses the "standard" gem)
- Use double quotes for strings
- Keep methods under 10 lines when possible
- Use snake_case for variables and methods
- Prefix instance variables with @
- Group requires at the top of files
- Use 2 spaces for indentation
- Use meaningful variable names
- Separate method definitions with a blank line
- Avoid global variables except for system outputs ($stdout)
- Add comments for complex logic or when purpose isn't obvious
- Prefer smaller, focused methods over large monolithic ones
- Use relative requires for local files
