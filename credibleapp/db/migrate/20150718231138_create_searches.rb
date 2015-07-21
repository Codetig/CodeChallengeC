class CreateSearches < ActiveRecord::Migration
  def change
    create_table :searches do |t|
      t.integer :user_id
      t.integer :prospect_id
      t.text :note

      t.timestamps null: false
    end
  end
end
