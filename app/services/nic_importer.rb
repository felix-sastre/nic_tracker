require "nokogiri"
require "open-uri"
require "csv"
require "date"

class NicImporter
  def initialize(input_date)
    @input_date = input_date
    @db_date = Date.strptime(input_date, "%d-%m-%Y")
  end

  def self.import_if_needed(input_date, db_date)
    return if Domain.exists?(registration_date: db_date)

    new(input_date).import
  end

  def import
    rdlist_url = "https://rdlist.nic.ar/rd_list/?date_filter=#{@input_date}"
    rdlist_page = Nokogiri::HTML(URI.open(rdlist_url))
    csv_node = rdlist_page.xpath("//table//tr/td/span/a").find { |node| node["href"].to_s.include?("csv") }

    if csv_node
      absolute_url = "https://rdlist.nic.ar#{csv_node['href']}"
      downloaded_data = URI.open(absolute_url).read

      CSV.parse(downloaded_data, headers: true, header_converters: :symbol).each do |row|
        import_row(row)
      end
    end
  end

  private

  def import_row(row)
    Domain.find_or_create_by!(nic_id: row[:id_dominio]) do |domain|
      domain.name = row[:dominio]
      domain.zone = row[:zona]
      domain.registration_date = @db_date
      domain.transaction_type = row[:tipo]
    end
  rescue ActiveRecord::RecordNotUnique
    retry
  end
end
