class Dashboard::UsersController < Dashboard::BaseController
  require 'csv'
  def index
    @merchant = current_user
    @users = User.current_costumers(@merchant)
   respond_to do |format|
     format.html
     format.csv { send_data @users.to_current_costumers_csv(@merchant) }
   end
  end
  
  def potential
    @merchant = current_user
    @users = User.potential_costumers(@merchant)
   respond_to do |format|
     format.html
     format.csv { send_data @users.to_potential_costumers_csv(@merchant) }
   end
  end
end
