module ExtraEtfParser
  extend self

  def get_url(isin, fund_type)
    validate_params(isin, fund_type)
    "https://extraetf.com/de/#{fund_type}-profile/#{isin}?tab=components"
  end

  def parse_html(doc)
    new_stock_list = ""
    stock_names = []

    rows = doc.css("#components table tr")

    if rows.empty?
      puts "Warning: No table rows found in HTML. HTML structure may have changed."
      return ["", "No holdings data found"]
    end

    rows.each do |row|
      stock_data = extract_stock_data(row)
      next if stock_data.nil?

      stock_name, pos, percent = stock_data
      new_stock_list += format_stock_line(pos, stock_name, percent)
      stock_names << stock_name
    end

    warn_if_no_stocks_found(stock_names)

    # Return sorted list of stock names for hash comparison
    # and full ordered list of stocks for output
    [stock_names.sort.join, new_stock_list]
  rescue => e
    puts "Error parsing HTML: #{e.message}"
    ["", "Error parsing HTML: #{e.message}"]
  end

  private

  def validate_params(isin, fund_type)
    if isin.nil? || isin.empty? || fund_type.nil? || fund_type.empty?
      raise ArgumentError, "Invalid ISIN or fund_type parameter"
    end
  end

  def extract_stock_data(row)
    stock_name = row.css(".col-name a").text.strip
    return nil if stock_name.empty?

    pos = row.css(".col-pos").text.strip
    percent = row.css(".col-val").text.strip
    [stock_name, pos, percent]
  rescue => e
    puts "Warning: Error parsing row: #{e.message}"
    nil
  end

  def format_stock_line(pos, stock_name, percent)
    "#{pos.ljust(2)} #{stock_name} (#{percent})\n"
  end

  def warn_if_no_stocks_found(stock_names)
    puts "Warning: No stocks found in parsed HTML" if stock_names.empty?
  end
end
