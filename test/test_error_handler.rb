require_relative "test_helper"
require_relative "../lib/utils/error_handler"

class TestErrorHandler < Minitest::Test
  def test_handle_processing_error_returns_false
    error = StandardError.new("something broke")
    result = capture_io { ErrorHandler.handle_processing_error(error) }.first

    assert_includes result, "something broke"
  end

  def test_handle_processing_error_returns_false_value
    error = StandardError.new("oops")
    value = nil
    capture_io { value = ErrorHandler.handle_processing_error(error) }
    assert_equal false, value
  end

  def test_warn_outputs_warning
    output = capture_io { ErrorHandler.warn("low disk space") }.first
    assert_includes output, "Warning: low disk space"
  end

  def test_handle_fatal_error_exits
    error = StandardError.new("db gone")
    assert_raises(SystemExit) do
      capture_io { ErrorHandler.handle_fatal_error(error) }
    end
  end

  def test_handle_connection_error_exits
    error = StandardError.new("timeout")
    assert_raises(SystemExit) do
      capture_io { ErrorHandler.handle_connection_error(error) }
    end
  end
end
