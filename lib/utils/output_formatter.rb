module OutputFormatter
  extend self

  # ANSI color codes
  GREEN = "\e[1;32m"
  RESET = "\e[0m"

  def print_progress(char = ".")
    print char
  end

  def print_newline_progress(char = ".")
    puts char
  end

  def print_change_detected(name)
    puts "\nChange detected in #{GREEN}#{name}#{RESET}:\n\n"
  end

  def print_green(text)
    puts "#{GREEN}#{text}"
  end

  def reset_color
    puts RESET
  end
end
