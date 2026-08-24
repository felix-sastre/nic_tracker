class CreateDomains < ActiveRecord::Migration[8.1]
  def change
    create_table :domains do |t|
      t.string :name
      t.string :zone
      t.date :registration_date
      t.string :nic_id
      t.string :transaction_type

      t.timestamps
    end
  end
end
