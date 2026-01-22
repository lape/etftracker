# ETFTrack Development Roadmap

## Current Features
- [x] Track ETF holdings from ExtraETF
- [x] Parse and display ETF composition data
- [x] SQLite database storage
- [x] Command-line interface with options
- [x] Show/hide funds without holdings data
- [x] TUI with progress bar during scraping
- [x] Before/after comparison table for changed holdings
- [x] Summary results table after scraping

## In Progress
- [ ] Mutual fund holdings tracking

## Planned Features

### Phase 1: Mutual Fund Support
- [ ] Research mutual fund data sources
  - [ ] Evaluate fondsweb.de for data availability
  - [ ] Check API availability vs web scraping requirements
  - [ ] Identify data structure and fields available
- [ ] Implement fondsweb.de parser
  - [ ] Create `parse_fondsweb.rb` module
  - [ ] Handle authentication if required
  - [ ] Parse fund holdings data
  - [ ] Map data to existing database schema
- [ ] Integrate mutual fund data into main application
  - [ ] Add fund type differentiation (ETF vs Mutual Fund)
  - [ ] Update database schema if needed
  - [ ] Extend CLI to handle mutual fund inputs
- [ ] Testing and validation
  - [ ] Add test cases for mutual fund parsing
  - [ ] Validate data accuracy
  - [ ] Handle edge cases and errors

### Phase 2: Enhanced Data Coverage
- [ ] Support multiple data sources per fund
- [ ] Implement fallback mechanisms for data retrieval
- [ ] Add more ETF data providers
- [ ] Historical holdings tracking

### Phase 3: Analysis Features
- [ ] Portfolio overlap analysis
- [ ] Sector/geography allocation breakdown
- [ ] Performance tracking
- [ ] Rebalancing suggestions

### Phase 4: User Interface Improvements
- [ ] Web interface for viewing holdings
- [ ] Export functionality (CSV, JSON)
- [ ] Comparison tools between funds
- [ ] Search and filter capabilities

## Technical Debt
- [ ] Add comprehensive test suite
- [ ] Improve error handling and logging
- [ ] Optimize database queries
- [ ] Add data caching layer
- [ ] Document API and modules

## Notes
- Mutual fund data availability varies significantly by provider
- May need to implement multiple scrapers for different fund families
- Consider rate limiting and respectful scraping practices