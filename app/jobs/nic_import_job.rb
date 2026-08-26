class NicImportJob < ApplicationJob
  queue_as :default

  def perform(input_date, db_date)
    NicImporter.import_if_needed(input_date, db_date)
  rescue NicImporter::FetchError => e
    Rails.logger.error(e.message)
  end
end
