require_relative "test_helper"
require_relative "../lib/tui/renderer"

class TestTuiRenderer < Minitest::Test
  def test_render_results_table_with_results
    results = [
      {name: "MSCI World", changed: true, time: Time.now},
      {name: "S&P 500", changed: false, time: Time.now - 7200}
    ]

    output = capture_io { Tui::Renderer.render_results_table(results) }.first
    assert_includes output, "MSCI World"
    assert_includes output, "S&P 500"
    assert_includes output, "Changed"
    assert_includes output, "No change"
  end

  def test_render_results_table_empty
    output = capture_io { Tui::Renderer.render_results_table([]) }.first
    assert_equal "", output
  end

  def test_render_progress_shows_percentage
    output = capture_io { Tui::Renderer.render_progress(1, 2, "Test ETF") }.first
    assert_includes output, "50%"
    assert_includes output, "Test ETF"
  end

  def test_render_holdings_box
    output = capture_io do
      Tui::Renderer.render_holdings_box("My ETF", "1  Apple (7%)\n2  Microsoft (6%)")
    end.first

    assert_includes output, "My ETF"
    assert_includes output, "Apple (7%)"
    assert_includes output, "Microsoft (6%)"
  end

  def test_render_holdings_box_with_nil_stock_list
    output = capture_io do
      Tui::Renderer.render_holdings_box("Empty ETF", nil)
    end.first

    assert_includes output, "No holdings data"
  end

  def test_format_time_never
    assert_equal "never", Tui::Renderer.send(:format_time, nil)
  end

  def test_format_time_just_now
    assert_equal "just now", Tui::Renderer.send(:format_time, Time.now - 10)
  end

  def test_format_time_minutes_ago
    result = Tui::Renderer.send(:format_time, Time.now - 300)
    assert_match(/\d+m ago/, result)
  end

  def test_format_time_hours_ago
    result = Tui::Renderer.send(:format_time, Time.now - 7200)
    assert_match(/\d+h ago/, result)
  end

  def test_format_time_old_date
    result = Tui::Renderer.send(:format_time, Time.now - 172800)
    assert_match(/\d{4}-\d{2}-\d{2}/, result)
  end

  def test_truncate_line_short
    assert_equal "hello", Tui::Renderer.send(:truncate_line, "hello", 10)
  end

  def test_truncate_line_long
    result = Tui::Renderer.send(:truncate_line, "a very long line indeed", 10)
    assert_equal 10, result.length
    assert result.end_with?("...")
  end
end
