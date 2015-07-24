class UsersController < ApplicationController
  # before_action **some method**, only: [:create]

  def update
    @user = User.find(session[:user_id])
    if @user.id == params[:id].to_i
      user_params[:tax_rate] = user_params[:tax_rate].to_i
      user_params[:term_months] = user_params[:term_months].to_i
      user_params[:annual_income] = user_params[:annual_income].to_i
      user_params[:down_pmt] = user_params[:down_pmt].to_i
      user_params[:budgeted_monthly_pmt] = user_params[:budgeted_monthly_pmt].to_i
      user_params[:monthly_debt] = user_params[:monthly_debt].to_i

      if @user.update_attributes(user_params)
        flash[:success] = "#{@user.first_name} profile updated"
        render root_path
      else
        redirect_to root_path, notice: "Please check your input for errors"
      end
    else
      redirect_to root_path, alert: "Update Failed: Permission denied"
    end
  end

  def create
    user =  User.new(user_params)
    if user.save
      session[:user_id] = user.id
      @user = user
      flash[:success] = "Success: Welcome #{user.first_name}"
      render "sites/index.html.erb"

    else
      redirect_to root_path, notice: "Sign Up Failed: Please ensure the form is correctly filled."
    end 
  end

  def login
    user = User.where(email: params["email"])[0] if params[:email].present? && params[:password].present?
    if user && user.authenticate(params["password"])
      session[:user_id] = user.id
      @user = user
      flash[:success] = "Welcome #{user.first_name}"
      render "sites/index.html.erb"
    else
      redirect_to :back, notice: "Login Failed: Please check your email and password"
    end
  end

  def logout
    session[:user_id] = nil
    flash[:success] = "You have logged out successfully"
    render "sites/index.html.erb"
  end

  private
  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :annual_income, :budgeted_monthly_pmt, :down_pmt, :monthly_debt, :tax_rate, :term_months)
  end
end
