class CreateProspects < ActiveRecord::Migration
  def change
    create_table :prospects do |t|
      t.boolean :saved_prospect
      t.text :parameters
      t.text :zillow_result

      t.timestamps null: false
    end
  end
end
