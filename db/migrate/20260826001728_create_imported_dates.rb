class CreateImportedDates < ActiveRecord::Migration[8.1]
  def change
    create_table :imported_dates do |t|
      t.date :registration_date, null: false
      t.integer :domains_count, null: false, default: 0
      t.datetime :imported_at, null: false
      t.timestamps
    end
    add_index :imported_dates, :registration_date, unique: true
  end
end
