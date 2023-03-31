# Parse ExtraETF holdings table

def get_url(isin)
  "https://de.extraetf.com/etf-profile/#{isin}?tab=components"
end

def parse_html(doc)
  new_stock_list = ""
  stock_names = []

  doc.css(".table-top-holdings tr").each do |row|
    stock_name = row.css(".col-name a").text.strip
    unless stock_name.empty?
      pos = row.css(".col-pos").text.strip
      percent = row.css(".col-val").text.strip
      new_stock_list += "#{pos.ljust(2)} #{stock_name} (#{percent})\n"
      stock_names << stock_name
    end
  end

  # Return sorted list of stock names for hash comparison
  # (so hash doesn't change if order of stocks changes)
  # and full ordered list of stocks for output (new_stock_list)
  [stock_names.sort.join, new_stock_list]
end
