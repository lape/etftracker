require "active_record"
require_relative "../utils/error_handler"
require_relative "../utils/output_formatter"

module Database
  extend self

  def connect!
    OutputFormatter.print_progress("Retrieving funds list.")
    OutputFormatter.print_progress

    validate_database_url
    establish_connection

    OutputFormatter.print_newline_progress
  end

  private

  def validate_database_url
    database_url = ENV["DATABASE_URL"]
    if database_url.nil? || database_url.empty?
      ErrorHandler.handle_fatal_error(
        StandardError.new("DATABASE_URL environment variable not set"),
        "ERROR"
      )
    end
  end

  def establish_connection
    ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"])
  rescue => e
    ErrorHandler.handle_connection_error(e)
  end
end
