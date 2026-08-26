class ImportedDate < ApplicationRecord
  validates :registration_date, presence: true, uniqueness: true
  validates :domains_count, presence: true
  validates :imported_at, presence: true
end
