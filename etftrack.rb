#!ruby
# Compare holdings of a ETF with a previous snapshot

# require "activerecord-cockroachdb-adapter"
require "sqlite3"
require "active_record"
require "digest"
require "dotenv/load"
require "httparty"
require "nokogiri"
require "optparse"
require_relative "parse_extraetf"

options = {}
OptionParser.new do |opt|
  opt.on("-s") { |o| options[:show] = true }
end.parse!

$stdout.sync = true
print "Retrieving funds list.."

begin
  database_url = ENV["DATABASE_URL"]
  if database_url.nil? || database_url.empty?
    puts "\nERROR: DATABASE_URL environment variable not set"
    exit 1
  end
  
  ActiveRecord::Base.establish_connection(database_url)
  print ".\n"
rescue => e
  puts "\nDatabase connection error: #{e.message}"
  exit 1
end

class Etf < ActiveRecord::Base
  def scrape!
    begin
      html = retrieve_html
      doc = Nokogiri::HTML(html)
      stock_names, new_stock_list = parse_html(doc) # from parse_extraetf.rb

      print ".\n"
      
      return false if stock_names.empty?
      
      current_hash = Digest::MD5.hexdigest stock_names
      if current_hash != last_hash
        output_and_save_changes(current_hash, new_stock_list)
        return true
      end
      return false
    rescue => e
      puts "\nError scraping #{name}: #{e.message}"
      return false
    end
  end

  def retrieve_html
    url = get_url(isin, fund_type) # from parse_extraetf.rb
    response = HTTParty.get(url, timeout: 10)
    
    unless response.code == 200
      raise "HTTP request failed with status #{response.code}"
    end
    
    response.body
  end

  def output_and_save_changes(current_hash, new_stock_list)
    puts "\nChange detected in \e[1;32m#{name}\e[0m:\n\n"
    puts "Before:\n"
    puts stock_list
    puts
    puts "\e[1;32mNow:\n"
    puts new_stock_list
    puts "\e[0m"

    self.last_hash = current_hash
    self.stock_list = new_stock_list
    self.time = Time.now
    begin
      save!
    rescue => e
      puts "Error saving changes: #{e.message}"
    end
  end
end

begin
  etfs = Etf.where(active: true).order(:id)
  
  if etfs.empty?
    puts "No active ETFs found in database."
    exit 0
  end
  
  etfs.each do |etf|
    print "Checking #{etf.name} ."
    # Wait a bit to not trip the server
    sleep 1
    print "."
    
    # scrape! returns true if change detected
    changes_detected = etf.scrape!
    
    unless changes_detected
      if options[:show] # Show all funds if -s flag is set
        puts
        puts etf.name
        puts etf.stock_list
        puts
      end
    end
  end
rescue => e
  puts "\nError processing ETFs: #{e.message}"
  exit 1
end
