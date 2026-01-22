require "active_record"
require "httparty"
require "nokogiri"
require "digest"
require_relative "../parsers/extraetf_parser"
require_relative "../tui/renderer"

class Etf < ActiveRecord::Base
  def scrape!
    html = retrieve_html
    doc = Nokogiri::HTML(html)
    stock_names, new_stock_list = ExtraEtfParser.parse_html(doc)

    return false if stock_names.empty?

    current_hash = Digest::MD5.hexdigest(stock_names)
    if current_hash != last_hash
      output_and_save_changes(current_hash, new_stock_list)
      return true
    end
    false
  rescue => e
    Tui::Renderer.clear_progress
    puts "\nError scraping #{name}: #{e.message}"
    false
  end

  private

  def retrieve_html
    url = ExtraEtfParser.get_url(isin, fund_type)
    response = HTTParty.get(url, timeout: 10)

    unless response.code == 200
      raise "HTTP request failed with status #{response.code}"
    end

    response.body
  end

  def output_and_save_changes(current_hash, new_stock_list)
    old_stock_list = stock_list

    Tui::Renderer.clear_progress
    Tui::Renderer.render_holdings_change(name, old_stock_list, new_stock_list)

    self.last_hash = current_hash
    self.stock_list = new_stock_list
    self.time = Time.now
    save!
  rescue => e
    puts "Error saving changes: #{e.message}"
  end
end
