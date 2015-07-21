class CreateProspects < ActiveRecord::Migration
  def change
    create_table :prospects do |t|
      t.boolean :basic_prospect
      t.boolean :save_prospect
      t.json :parameters
      t.json :zillow_result

      t.timestamps null: false
    end
  end
end
