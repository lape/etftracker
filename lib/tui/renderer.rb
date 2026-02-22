require "io/console"
require "ratatui_ruby"

module Tui
  module Renderer
    extend self

    PROGRESS_BAR_WIDTH = 20
    MIN_TABLE_WIDTH = 70

    def table_width
      width = begin
        IO.console_size[1]
      rescue
        120
      end
      [width - 2, MIN_TABLE_WIDTH].max
    end

    # Renders an inline progress bar during ETF scraping
    def render_progress(current, total, etf_name)
      filled = (current.to_f / total * PROGRESS_BAR_WIDTH).round
      empty = PROGRESS_BAR_WIDTH - filled
      bar = "\u2588" * filled + "\u2591" * empty
      percentage = ((current.to_f / total) * 100).round

      # Truncate ETF name if too long
      max_name_length = 40
      display_name = (etf_name.length > max_name_length) ? "#{etf_name[0...max_name_length - 3]}..." : etf_name

      print "\r\e[K"
      print "Scraping ETFs: #{bar} #{current}/#{total} (#{percentage}%)  Current: #{display_name}"
      $stdout.flush
    end

    # Clears the progress line when done
    def clear_progress
      print "\r\e[K"
      $stdout.flush
    end

    # Renders a before/after holdings comparison table
    def render_holdings_change(etf_name, old_holdings, new_holdings)
      puts
      render_change_header(etf_name)
      render_side_by_side_holdings(old_holdings, new_holdings)
      render_box_bottom
      puts
    end

    # Renders the final results summary table
    def render_results_table(results)
      return if results.empty?

      puts
      render_results_header
      render_results_rows(results)
      render_table_bottom
      puts
    end

    # Renders a single fund's holdings in a styled box
    def render_holdings_box(etf_name, stock_list)
      title = " #{etf_name} "
      padding = table_width - title.length - 1
      padding = 0 if padding.negative?

      puts "\e[36m\u250c\u2500#{title}#{"\u2500" * padding}\u2510\e[0m"

      lines = (stock_list || "No holdings data").split("\n")
      max_display = [lines.length, 15].min
      inner = table_width - 1

      max_display.times do |i|
        line = truncate_line(lines[i] || "", inner)
        puts "\e[36m\u2502\e[0m #{line.ljust(inner)}\e[36m\u2502\e[0m"
      end

      if lines.length > max_display
        remaining = lines.length - max_display
        msg = "... and #{remaining} more holdings"
        puts "\e[36m\u2502\e[0m #{msg.ljust(inner)}\e[36m\u2502\e[0m"
      end

      puts "\e[36m\u2514#{"\u2500" * table_width}\u2518\e[0m"
    end

    private

    def render_change_header(etf_name)
      title = " Change detected: #{etf_name} "
      padding = table_width - title.length - 2
      padding = 0 if padding.negative?

      puts "\e[1;32m\u250c\u2500#{title}#{"\u2500" * padding}\u2510\e[0m"
      puts "\e[1;32m\u2502#{" " * table_width}\u2502\e[0m"
    end

    def render_side_by_side_holdings(old_holdings, new_holdings)
      old_lines = (old_holdings || "No previous data").split("\n")
      new_lines = (new_holdings || "").split("\n")

      col_width = (table_width - 5) / 2

      # Headers
      before_header = "Before:".ljust(col_width)
      now_header = "Now:".ljust(col_width)
      puts "\e[1;32m\u2502\e[0m  #{before_header} \e[1;32m\u2502\e[0m \e[1;32m#{now_header}\e[0m \e[1;32m\u2502\e[0m"

      # Separator
      puts "\e[1;32m\u2502\e[0m  #{"\u2500" * col_width} \e[1;32m\u2502\e[0m #{"\u2500" * col_width} \e[1;32m\u2502\e[0m"

      # Content rows
      max_lines = [old_lines.length, new_lines.length].max
      max_display = [max_lines, 15].min

      max_display.times do |i|
        old_line = truncate_line(old_lines[i] || "", col_width)
        new_line = truncate_line(new_lines[i] || "", col_width)
        puts "\e[1;32m\u2502\e[0m  #{old_line.ljust(col_width)} \e[1;32m\u2502\e[0m \e[1;32m#{new_line.ljust(col_width)}\e[0m \e[1;32m\u2502\e[0m"
      end

      if max_lines > max_display
        remaining = max_lines - max_display
        msg = "... and #{remaining} more lines"
        puts "\e[1;32m\u2502\e[0m  #{msg.ljust(col_width)} \e[1;32m\u2502\e[0m #{" " * col_width} \e[1;32m\u2502\e[0m"
      end

      puts "\e[1;32m\u2502#{" " * table_width}\u2502\e[0m"
    end

    def render_box_bottom
      puts "\e[1;32m\u2514#{"\u2500" * table_width}\u2518\e[0m"
    end

    def name_col_width
      # Fixed columns: "│  #  │" (6) + "│ Status    │" (12) + "│ Last Change │" (14) + separators
      # Total fixed = 5 + 1 + 11 + 1 + 13 + 3 borders = 34
      table_width - 34
    end

    def render_results_header
      nw = name_col_width
      puts "\u250c\u2500\u2500\u2500\u2500\u2500\u252c#{"\u2500" * (nw + 2)}\u252c\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u252c\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2510"
      puts "\u2502  #  \u2502 #{"ETF Name".ljust(nw)} \u2502 Status    \u2502 Last Change \u2502"
      puts "\u251c\u2500\u2500\u2500\u2500\u2500\u253c#{"\u2500" * (nw + 2)}\u253c\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u253c\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2524"
    end

    def render_results_rows(results)
      nw = name_col_width
      results.each_with_index do |result, index|
        num = (index + 1).to_s.rjust(3)
        name = truncate_line(result[:name], nw)
        status = format_status(result[:changed])
        time = format_time(result[:time])

        puts "\u2502 #{num} \u2502 #{name.ljust(nw)} \u2502 #{status} \u2502 #{time.ljust(11)} \u2502"
      end
    end

    def render_table_bottom
      nw = name_col_width
      puts "\u2514\u2500\u2500\u2500\u2500\u2500\u2534#{"\u2500" * (nw + 2)}\u2534\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2534\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2518"
    end

    def truncate_line(line, max_length)
      return line if line.length <= max_length
      "#{line[0...max_length - 3]}..."
    end

    def format_status(changed)
      if changed
        "\e[1;32mChanged\e[0m  "
      else
        "No change"
      end
    end

    def format_time(time)
      return "never" unless time

      seconds_ago = Time.now - time
      if seconds_ago < 60
        "just now"
      elsif seconds_ago < 3600
        "#{(seconds_ago / 60).round}m ago"
      elsif seconds_ago < 86400
        "#{(seconds_ago / 3600).round}h ago"
      else
        time.strftime("%Y-%m-%d")
      end
    end
  end
end
