class AddIndexesToDomains < ActiveRecord::Migration[8.1]
  def change
    add_index :domains, :registration_date
    add_index :domains, :nic_id, unique: true
  end
end
