class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  protected
  
  def authorize_admin!
    unless current_user && current_user.admin?
      flash[:alert] = "You must be an admin to access this page."
      redirect_to root_path
    end
  end
  
  def current_user_admin?
    current_user && current_user.admin?
  end
  
  helper_method :current_user_admin?
end

