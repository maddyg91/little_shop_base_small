class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :current_user, :current_merchant?, :current_admin?, :require_current_user

  before_action :build_cart

  def current_user
    @current_user_lookup ||= User.find(session[:user_id]) if session[:user_id]
  end

  def current_merchant?
    current_user && current_user.merchant?
  end

  def current_admin?
    current_user && current_user.admin?
  end

  def require_current_user
    render file: "/public/404", status: :not_found unless current_user
  end

  def build_cart
    @cart ||= Cart.new(session[:cart])
  end
end
