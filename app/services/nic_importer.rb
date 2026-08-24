require "nokogiri"
require "open-uri"
require "csv"
require "date"

class NicImporter
  def initialize(input_date)
    @input_date = input_date
    @db_date = Date.strptime(input_date, "%d-%m-%Y")
  end

  def import
    rdlist_url = "https://rdlist.nic.ar/rd_list/?date_filter=#{@input_date}"
    rdlist_page = Nokogiri::HTML(URI.open(rdlist_url))
    csv_node = rdlist_page.xpath("//table//tr/td/span/a").find { |node| node["href"].to_s.include?("csv") }

    if csv_node
      absolute_url = "https://rdlist.nic.ar#{csv_node['href']}"
      downloaded_data = URI.open(absolute_url).read

      CSV.parse(downloaded_data, headers: true, header_converters: :symbol).each do |row|
        Domain.create(
          name: row[:dominio],
          zone: row[:zona],
          registration_date: @db_date,
          nic_id: row[:id_dominio],
          transaction_type: row[:tipo]
        )
      end
    end
  end
end
