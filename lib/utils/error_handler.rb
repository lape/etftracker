module ErrorHandler
  extend self

  def handle_connection_error(error, message = "Database connection error")
    puts "\n#{message}: #{error.message}"
    exit 1
  end

  def handle_fatal_error(error, message = "Fatal error")
    puts "\n#{message}: #{error.message}"
    exit 1
  end

  def handle_processing_error(error, message = "Error")
    puts "\n#{message}: #{error.message}"
    false
  end

  def warn(message)
    puts "Warning: #{message}"
  end
end
