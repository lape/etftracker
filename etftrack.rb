#!ruby
# Compare holdings of a ETF with a previous snapshot

require "active_record"
require "activerecord-cockroachdb-adapter"
require "digest"
require "dotenv/load"
require "httparty"
require "nokogiri"
require_relative "parse_extraetf"

ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"])

class Etf < ActiveRecord::Base
  def scrape!
    # TODO: #1 Support ETF-individual page parsers
    html = retrieve_html
    doc = Nokogiri::HTML(html)
    stock_names, new_stock_list = parse_html(doc) # from parse_extraetf.rb

    current_hash = Digest::MD5.hexdigest stock_names
    output_and_save_changes(current_hash, new_stock_list) if current_hash != last_hash
  end

  def retrieve_html
    url = get_url(isin) # from parse_extraetf.rb
    response = HTTParty.get(url)
    response.body
  end

  def output_and_save_changes(current_hash, new_stock_list)
    puts "\nChange detected in \e[1;32m#{name}\e[0m:\n"
    puts "Before:\n"
    puts stock_list
    puts
    puts "Now:\n"
    puts new_stock_list
    puts

    self.last_hash = current_hash
    self.stock_list = new_stock_list
    self.time = Time.now
    self.save!
  end
end

Etf.all.each do |etf|
  puts "Scraping #{etf.name}..."
  etf.scrape!
  sleep 2
end
