class DomainsController < ApplicationController
  before_action :set_domain, only: %i[ show edit update destroy ]

  # GET /domains or /domains.json
  def index
    @input_date = params[:fecha] || "01-10-2018"

    @current_page = (params[:page] || 1).to_i
    @current_page = 1 if @current_page < 1
    per_page = 20

    db_date = parse_valid_date(@input_date)

    if db_date.nil?
      @domains = []
      @error = "Invalid date format. Please use DD-MM-YYYY."
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

  # GET /domains/1 or /domains/1.json
  def show
  end

  # GET /domains/new
  def new
    @domain = Domain.new
  end

  # GET /domains/1/edit
  def edit
  end

  # POST /domains or /domains.json
  def create
    @domain = Domain.new(domain_params)

    respond_to do |format|
      if @domain.save
        format.html { redirect_to @domain, notice: "Domain was successfully created." }
        format.json { render :show, status: :created, location: @domain }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @domain.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /domains/1 or /domains/1.json
  def update
    respond_to do |format|
      if @domain.update(domain_params)
        format.html { redirect_to @domain, notice: "Domain was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @domain }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @domain.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /domains/1 or /domains/1.json
  def destroy
    @domain.destroy!

    respond_to do |format|
      format.html { redirect_to domains_path, notice: "Domain was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_domain
      @domain = Domain.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def domain_params
      params.expect(domain: [ :name, :zone, :registration_date, :nic_id, :transaction_type ])
    end

    def parse_valid_date(date_string)
      begin
        Date.strptime(date_string, "%d-%m-%Y")
      rescue Date::Error, ArgumentError, TypeError
        nil
      end
    end
end
