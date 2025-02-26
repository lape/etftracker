# Parse ExtraETF holdings table

def get_url(isin, fund_type)
  if isin.nil? || isin.empty? || fund_type.nil? || fund_type.empty?
    raise "Invalid ISIN or fund_type parameter"
  end
  
  "https://extraetf.com/de/#{fund_type}-profile/#{isin}?tab=components"
end

def parse_html(doc)
  new_stock_list = ""
  stock_names = []

  begin
    rows = doc.css("#components table tr")
    
    if rows.empty?
      puts "Warning: No table rows found in HTML. HTML structure may have changed."
      return ["", "No holdings data found"]
    end

    rows.each do |row|
      begin
        stock_name = row.css(".col-name a").text.strip
        unless stock_name.empty?
          pos = row.css(".col-pos").text.strip
          percent = row.css(".col-val").text.strip
          new_stock_list += "#{pos.ljust(2)} #{stock_name} (#{percent})\n"
          stock_names << stock_name
        end
      rescue => e
        puts "Warning: Error parsing row: #{e.message}"
      end
    end

    if stock_names.empty?
      puts "Warning: No stocks found in parsed HTML"
    end

    # Return sorted list of stock names for hash comparison
    # (so hash doesn't change if order of stocks changes)
    # and full ordered list of stocks for output (new_stock_list)
    [stock_names.sort.join, new_stock_list]
  rescue => e
    puts "Error parsing HTML: #{e.message}"
    ["", "Error parsing HTML: #{e.message}"]
  end
end
