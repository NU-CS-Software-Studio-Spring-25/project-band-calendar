class SessionsController < ApplicationController
    def create
        user = User.find_by(email: params[:email])

        if user && user.valid_password?(params[:password])
          sign_in(user)
          flash[:notice] = "Login successful!"
          redirect_to root_path
        else
          rflash[:notice] = "Invalid email or password."
          redirect_to new_user_session_path
        end
      end
end
