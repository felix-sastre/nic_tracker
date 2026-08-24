class CreateDomainStatuses < ActiveRecord::Migration[8.1]
  def change
    create_table :domain_statuses do |t|
      t.references :domain, null: false, foreign_key: true
      t.boolean :is_online
      t.datetime :checked_at

      t.timestamps
    end
  end
end
