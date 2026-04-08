require_relative "test_helper"
require_relative "../lib/utils/output_formatter"

class TestOutputFormatter < Minitest::Test
  def test_print_change_detected_includes_name
    output = capture_io { OutputFormatter.print_change_detected("MSCI World") }.first
    assert_includes output, "MSCI World"
    assert_includes output, "Change detected"
  end

  def test_print_green_includes_text
    output = capture_io { OutputFormatter.print_green("hello") }.first
    assert_includes output, "hello"
    assert_includes output, "\e[1;32m"
  end

  def test_print_progress_outputs_dot
    output = capture_io { OutputFormatter.print_progress }.first
    assert_equal ".", output
  end

  def test_print_progress_custom_char
    output = capture_io { OutputFormatter.print_progress("*") }.first
    assert_equal "*", output
  end
end
