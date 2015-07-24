class User < ActiveRecord::Base
  validates :first_name, :last_name, :email, presence: true
  validates :email, uniqueness: true
  validates :annual_income, :budgeted_monthly_pmt, :down_pmt, :monthly_debt, numericality: true

  has_secure_password
  has_many :searches
  has_many :prospects, through: :searches

  def update p_hash
    @tax_rate = p_hash[:tax_rate].to_i
    @term_months = p_hash[:term_months].to_i
    @annual_income = p_hash[:annual_income].to_i
    @down_pmt = p_hash[:down_pmt].to_i
    @budgeted_monthly_pmt = p_hash[:budgeted_monthly_pmt].to_i
    @monthly_debt = p_hash[:monthly_debt].to_i
    @first_name = p_hash[:first_name]
    @last_name = p_hash[:last_name]
    @email = p_hash[:email]
    self.save
  end

  def self.update_helper(att, value)

  end
end