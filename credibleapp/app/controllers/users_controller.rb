class UsersController < ApplicationController
  def show
  end

  def edit
  end

  def login
    user = User.where(email: params["email"])[0] if params[:email].present? && params[:password].present?
    if user && user.authenticate(params["password"])
      session[:user_id] = user.id
      @user = user
      redirect_to root_path, success: "Welcome #{user.first_name}"
    else
      redirect_to :back, notice: "Login Failed: Please check your email and password try"
    end
  end

  def create
    user =  User.new user_params
    if user.save
      sessions[user_id] = user.user_id
    end

    redirect_to root_path, success: "Success: Welcome #{user.first_name}"
  end

  private
  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :annual_income, :budgeted_monthly_pmt, :down_pmt, :monthly_debt, :tax_rate, :term_months)
  end
end
