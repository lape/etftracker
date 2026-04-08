require_relative "test_helper"
require "nokogiri"
require_relative "../lib/parsers/extraetf_parser"

class TestExtraEtfParser < Minitest::Test
  def test_get_url_for_etf
    url = ExtraEtfParser.get_url("IE00B4L5Y983", "etf")
    assert_equal "https://extraetf.com/de/etf-profile/IE00B4L5Y983?tab=components", url
  end

  def test_get_url_for_fund
    url = ExtraEtfParser.get_url("LU0392494562", "fund")
    assert_equal "https://extraetf.com/de/fund-profile/LU0392494562?tab=components", url
  end

  def test_get_url_raises_on_empty_isin
    assert_raises(ArgumentError) { ExtraEtfParser.get_url("", "etf") }
  end

  def test_get_url_raises_on_nil_isin
    assert_raises(ArgumentError) { ExtraEtfParser.get_url(nil, "etf") }
  end

  def test_get_url_raises_on_empty_fund_type
    assert_raises(ArgumentError) { ExtraEtfParser.get_url("IE00B4L5Y983", "") }
  end

  def test_parse_html_with_valid_table
    html = <<~HTML
      <div id="components">
        <table>
          <tr>
            <td class="col-name"><a>Apple Inc.</a></td>
            <td class="col-pos">1</td>
            <td class="col-val">7.20%</td>
          </tr>
          <tr>
            <td class="col-name"><a>Microsoft Corp.</a></td>
            <td class="col-pos">2</td>
            <td class="col-val">6.50%</td>
          </tr>
        </table>
      </div>
    HTML

    doc = Nokogiri::HTML(html)
    stock_names, stock_list = ExtraEtfParser.parse_html(doc)

    assert_includes stock_names, "Apple Inc."
    assert_includes stock_names, "Microsoft Corp."
    assert_includes stock_list, "Apple Inc. (7.20%)"
    assert_includes stock_list, "Microsoft Corp. (6.50%)"
  end

  def test_parse_html_returns_sorted_stock_names
    html = <<~HTML
      <div id="components">
        <table>
          <tr>
            <td class="col-name"><a>Zebra Tech</a></td>
            <td class="col-pos">1</td>
            <td class="col-val">5%</td>
          </tr>
          <tr>
            <td class="col-name"><a>Apple Inc.</a></td>
            <td class="col-pos">2</td>
            <td class="col-val">3%</td>
          </tr>
        </table>
      </div>
    HTML

    doc = Nokogiri::HTML(html)
    stock_names, _ = ExtraEtfParser.parse_html(doc)

    assert_equal "Apple Inc.Zebra Tech", stock_names
  end

  def test_parse_html_with_empty_table
    html = '<div id="components"><table></table></div>'
    doc = Nokogiri::HTML(html)

    stock_names, stock_list = ExtraEtfParser.parse_html(doc)

    assert_equal "", stock_names
    assert_equal "No holdings data found", stock_list
  end

  def test_parse_html_skips_rows_without_name
    html = <<~HTML
      <div id="components">
        <table>
          <tr><th>Name</th><th>Pos</th><th>%</th></tr>
          <tr>
            <td class="col-name"><a>Apple Inc.</a></td>
            <td class="col-pos">1</td>
            <td class="col-val">7.20%</td>
          </tr>
        </table>
      </div>
    HTML

    doc = Nokogiri::HTML(html)
    stock_names, stock_list = ExtraEtfParser.parse_html(doc)

    assert_includes stock_names, "Apple Inc."
    refute_includes stock_list, "Name"
  end
end
