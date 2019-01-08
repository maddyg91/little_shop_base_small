class Dashboard::UsersController < Dashboard::BaseController
  require 'csv'
  def index
    @merchant = current_user
    @users = User.current_users(@merchant)
   respond_to do |format|
     format.html
     format.csv { send_data @users.to_csv }
   end
  end
end
