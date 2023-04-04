#!ruby
# Compare holdings of a ETF with a previous snapshot

require "active_record"
require "activerecord-cockroachdb-adapter"
require "digest"
require "dotenv/load"
require "httparty"
require "nokogiri"
require "optparse"
require_relative "parse_extraetf"

options = {}
OptionParser.new do |opt|
  opt.on('-s') { |o| options[:show] = true }
end.parse!

$stdout.sync = true
print "Retrieving funds list.."
ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"])
print ".\n"

class Etf < ActiveRecord::Base
  def scrape!
    # TODO: #1 Support ETF-individual page parsers
    html = retrieve_html
    doc = Nokogiri::HTML(html)
    stock_names, new_stock_list = parse_html(doc) # from parse_extraetf.rb

    print ".\n"

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
    save
  end
end

Etf.all.order(:name).each do |etf|
  print "Checking #{etf.name} ."
  # Wait a bit to not trip the server
  sleep 1
  print "."
  unless etf.scrape!  # scrape! returns true if change detected
    if options[:show] # Show all funds if -s flag is set
      puts
      puts "#{etf.name}"
      puts "#{etf.stock_list}"
      puts
    end
  end
end
