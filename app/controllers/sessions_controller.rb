class SessionsController < Devise::SessionsController
  before_action :check_admin?, except: [:destroy]
  before_action :authenticate_user!, only: [:destroy]
  
  def new; end
  
  def create
    debugger
    sessions = params[:session]
    @user = User.find_by(email: sessions[:email].downcase)
    if @user&.authenticate?(sessions[:password])
      login
      redirect_to admin_root_path && return if is_admin?
    else
      flash.now[:error] = t "common.flash.login_invalid"
      render :new
    end
  end

  def destroy
    logout_user
  end

  private

  def login
    loggin_user(@user)
    remember = params[:session][:remember]
    remember == "1" ? remember_user(@user) : forgot_user(@user)
    flash[:success] = t "common.flash.login_success"
    redirect_to session[:forwarding_url] || root_path
    session[:forwarding_url] = ""
  end
end
