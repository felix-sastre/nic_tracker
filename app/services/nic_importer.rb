require "nokogiri"
require "open-uri"
require "csv"
require "date"

class NicImporter
  class FetchError < StandardError; end

  def initialize(input_date)
    @input_date = input_date
    @db_date = Date.strptime(input_date, "%d-%m-%Y")
  end

  def self.import_if_needed(input_date, db_date)
    return if ImportedDate.exists?(registration_date: db_date)

    imported_date = claim(db_date)
    return unless imported_date # another request already claimed this date; let it do the fetch

    begin
      new(input_date).import(imported_date)
    rescue StandardError
      imported_date.destroy # release the claim so a later request can retry the fetch
      raise
    end
  end

  # Atomically claims a date for import, so a concurrent request for the same
  # never-seen-before date doesn't also hit nic.ar: only the request whose
  # INSERT wins the unique index on registration_date proceeds to fetch.
  def self.claim(db_date)
    imported_date = ImportedDate.create(registration_date: db_date, domains_count: 0, imported_at: Time.current)
    imported_date if imported_date.persisted?
  rescue ActiveRecord::RecordNotUnique
    nil
  end

  def import(imported_date)
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

    imported_date.update!(domains_count: Domain.where(registration_date: @db_date).count, imported_at: Time.current)
  rescue SocketError, OpenURI::HTTPError, Timeout::Error, SystemCallError => e
    raise FetchError, "Failed to fetch nic.ar data: #{e.class} - #{e.message}"
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
