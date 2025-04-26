#!/usr/bin/env ruby
# Compare holdings of an ETF with a previous snapshot

require "optparse"
require "dotenv/load"
require "active_record"
require "httparty"
require "nokogiri"
require "digest"
require_relative "parse_extraetf"

class Etf < ActiveRecord::Base
  def scrape!
    begin
      html = retrieve_html
      doc = Nokogiri::HTML(html)
      stock_names, new_stock_list = parse_html(doc)

      print ".\n"
      
      return false if stock_names.empty?
      
      current_hash = Digest::MD5.hexdigest(stock_names)
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
    url = get_url(isin, fund_type)
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

def parse_options
  options = {}
  OptionParser.new do |opt|
    opt.on("-s", "Show all funds") { |o| options[:show] = true }
  end.parse!
  options
end

def connect_to_database
  print "Retrieving funds list.."
  
  database_url = ENV["DATABASE_URL"]
  if database_url.nil? || database_url.empty?
    puts "\nERROR: DATABASE_URL environment variable not set"
    exit 1
  end
  
  begin  
    ActiveRecord::Base.establish_connection(database_url)
    print ".\n"
  rescue => e
    puts "\nDatabase connection error: #{e.message}"
    exit 1
  end
end

def process_etfs(options)
  etfs = Etf.where(active: true).order(:id)
  
  if etfs.empty?
    puts "No active ETFs found in database."
    exit 0
  end
  
  etfs.each do |etf|
    print "Checking #{etf.name} ."
    print "."
    
    changes_detected = etf.scrape!
    
    if !changes_detected && options[:show]
      puts
      puts etf.name
      puts etf.stock_list
      puts
    end
  end
end

def main
  $stdout.sync = true
  options = parse_options
  connect_to_database
  
  begin
    process_etfs(options)
  rescue => e
    puts "\nError processing ETFs: #{e.message}"
    exit 1
  end
end

main