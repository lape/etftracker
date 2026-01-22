require "ratatui_ruby"

module Tui
  module Renderer
    extend self

    PROGRESS_BAR_WIDTH = 20
    TABLE_WIDTH = 70

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

    private

    def render_change_header(etf_name)
      title = " Change detected: #{etf_name} "
      padding = TABLE_WIDTH - title.length - 2
      padding = 0 if padding.negative?

      puts "\e[1;32m\u250c\u2500#{title}#{"\u2500" * padding}\u2510\e[0m"
      puts "\e[1;32m\u2502#{" " * TABLE_WIDTH}\u2502\e[0m"
    end

    def render_side_by_side_holdings(old_holdings, new_holdings)
      old_lines = (old_holdings || "No previous data").split("\n")
      new_lines = (new_holdings || "").split("\n")

      col_width = (TABLE_WIDTH - 5) / 2

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

      puts "\e[1;32m\u2502#{" " * TABLE_WIDTH}\u2502\e[0m"
    end

    def render_box_bottom
      puts "\e[1;32m\u2514#{"\u2500" * TABLE_WIDTH}\u2518\e[0m"
    end

    def render_results_header
      puts "\u250c\u2500\u2500\u2500\u2500\u2500\u252c#{"\u2500" * 36}\u252c\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u252c\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2510"
      puts "\u2502  #  \u2502 ETF Name                           \u2502 Status    \u2502 Last Change \u2502"
      puts "\u251c\u2500\u2500\u2500\u2500\u2500\u253c#{"\u2500" * 36}\u253c\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u253c\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2524"
    end

    def render_results_rows(results)
      results.each_with_index do |result, index|
        num = (index + 1).to_s.rjust(3)
        name = truncate_line(result[:name], 34)
        status = format_status(result[:changed])
        time = format_time(result[:time])

        puts "\u2502 #{num} \u2502 #{name.ljust(34)} \u2502 #{status} \u2502 #{time.ljust(11)} \u2502"
      end
    end

    def render_table_bottom
      puts "\u2514\u2500\u2500\u2500\u2500\u2500\u2534#{"\u2500" * 36}\u2534\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2534\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2518"
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
