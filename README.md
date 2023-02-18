# Track ETF holdings over time

Simple Ruby script to scrape the top ten stock holding composition of an ETF by ISIN and compare to previously saved hash values. Useful to be aware of rebalancing changes.

In this case, CockroachDB is used for storing the data. But of course, it would also be easily possible to just save the data in an SQLite database. Create .env with database URL from .env.template file. The file etfs.sql contains the table structure.

The data is pulled from ExtraETF, the site-specific code is contained in parse_extraetf.rb. If the page changes or another provider should be used, adapt or create a new parser.
