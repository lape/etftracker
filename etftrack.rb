#!ruby
# Compare holdings of a ETF with a previous snapshot

require "active_record"
require "activerecord-cockroachdb-adapter"
require "digest"
require "dotenv/load"
require "httparty"
require "nokogiri"

ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"])

class Etf < ActiveRecord::Base
  def scrape!
    html = retrieve_html
    doc = Nokogiri::HTML(html)
    stock_names = new_stock_list = ""

    doc.css('.table-top-holdings tr').each do |row|
      stock_name = row.css('.col-name a').text.strip
      unless stock_name.empty?
        pos = row.css('.col-pos').text.strip
        percent = row.css('.col-val').text.strip
        new_stock_list += "#{pos.ljust(2)} #{stock_name} (#{percent})\n"
        stock_names += stock_name
      end
    end

    current_hash = Digest::MD5.hexdigest stock_names
    if current_hash != last_hash
      output_and_save_changes(current_hash, new_stock_list)
    end
  end

  def retrieve_html
    url = "https://de.extraetf.com/etf-profile/#{isin}?tab=components"
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
    self.save!
  end
end

Etf.all.each do |etf|
  puts "Scraping #{etf.name}..."
  etf.scrape!
  sleep 2
end
