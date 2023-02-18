#!ruby
# Parse ExtraETF holdings table

def get_url(isin)
  "https://de.extraetf.com/etf-profile/#{isin}?tab=components"
end

def parse_html(doc)
  stock_names = new_stock_list = ""

  doc.css('.table-top-holdings tr').each do |row|
    stock_name = row.css('.col-name a').text.strip
    unless stock_name.empty?
      pos = row.css('.col-pos').text.strip
      percent = row.css('.col-val').text.strip
      new_stock_list += "#{pos.ljust(2)} #{stock_name} (#{percent})\n"
      stock_names += stock_name
    end
  end

  return stock_names, new_stock_list
end
