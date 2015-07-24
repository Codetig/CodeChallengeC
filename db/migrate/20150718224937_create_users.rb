class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :password
      t.string :password_digest
      t.decimal :annual_income, :budgeted_monthly_pmt, :down_pmt, :monthly_debt, :precision => 12, :scale => 2, default: 0
      t.integer :tax_rate
      t.integer :term_months

      t.timestamps null: false
    end
  end
end
