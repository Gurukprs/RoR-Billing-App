class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  
  def authenticate_admin!
    redirect_to root_path, alert: "Access denied" unless current_user&.admin?
  end
  
  def after_sign_in_path_for(resource)
    if resource.admin?
      admin_products_path
    else
      root_path
    end
  end
end
