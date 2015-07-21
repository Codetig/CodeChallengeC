class User < ActiveRecord::Base
  validates :first_name, :last_name, :email, :password, presence: true
  validates :email, uniqueness: true
  validates :annual_income, :budgeted_monthly_pmt, :down_pmt, :monthly_debt, numericality: true

  has_secure_password
  has_many :searches
  has_many :prospects, through: :searches
end