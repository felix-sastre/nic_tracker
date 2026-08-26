class DomainsController < ApplicationController
  # GET /domains or /domains.json
  def index
    @input_date = params[:fecha] || "01-10-2018"

    @current_page = (params[:page] || 1).to_i
    @current_page = 1 if @current_page < 1
    per_page = 20

    db_date = parse_valid_date(@input_date)

    if db_date.nil?
      @domains = []
      @error = "Formato de fecha inválido. Usá DD-MM-YYYY."
      return
    end

    unless ImportedDate.exists?(registration_date: db_date)
      NicImportJob.perform_later(@input_date, db_date)
      @domains = []
      @importing = true
      return
    end

    offset = (@current_page - 1) * per_page
    @total_records = Domain.where(registration_date: db_date).count
    @total_pages = (@total_records / per_page.to_f).ceil

    @domains = Domain.where(registration_date: db_date)
                    .limit(per_page)
                    .offset(offset)
                    .includes(:domain_status)

    @domains.each do |domain|
      DomainStatusCheckJob.perform_later(domain.id) unless domain.domain_status
    end
  end

  private

  def parse_valid_date(date_string)
    Date.strptime(date_string, "%d-%m-%Y")
  rescue Date::Error, ArgumentError, TypeError
    nil
  end
end
