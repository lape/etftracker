#!/usr/bin/env ruby

require "optparse"
require "dotenv/load"
require_relative "lib/config/database"
require_relative "lib/models/etf"
require_relative "lib/tui/renderer"
require_relative "lib/utils/error_handler"

class EtfTracker
  def initialize
    $stdout.sync = true
    @options = parse_options
    @results = []
  end

  def run
    Database.connect!
    process_etfs
  rescue => e
    ErrorHandler.handle_fatal_error(e, "Error processing ETFs")
  end

  private

  def parse_options
    options = {}
    OptionParser.new do |opt|
      opt.on("-s", "Show all funds") { |o| options[:show] = true }
    end.parse!
    options
  end

  def process_etfs
    etfs = Etf.where(active: true).order(:id)

    if etfs.empty?
      puts "No active ETFs found in database."
      exit 0
    end

    total = etfs.count
    etfs.each_with_index do |etf, index|
      Tui::Renderer.render_progress(index + 1, total, etf.name)
      process_single_etf(etf)
    end

    Tui::Renderer.clear_progress
    display_results
  end

  def process_single_etf(etf)
    changes_detected = etf.scrape!

    @results << {
      name: etf.name,
      changed: changes_detected,
      time: etf.time
    }

    display_unchanged_fund(etf) if should_display_unchanged?(changes_detected)
  end

  def should_display_unchanged?(changes_detected)
    !changes_detected && @options[:show]
  end

  def display_unchanged_fund(etf)
    Tui::Renderer.clear_progress
    puts
    puts etf.name
    puts etf.stock_list
  end

  def display_results
    Tui::Renderer.render_results_table(@results)
  end
end

# Main execution
if __FILE__ == $0
  EtfTracker.new.run
end
