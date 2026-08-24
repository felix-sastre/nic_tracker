class Domain < ApplicationRecord
  has_one :domain_status, dependent: :destroy

  validates :name, presence: true
  validates :zone, presence: true
  validates :registration_date, presence: true
  validates :nic_id, presence: true, uniqueness: true
end
