class SessionsController < ApplicationController
  skip_before_action :require_authentication, only: %i[new create]

  layout "auth"

  def new
    redirect_to root_path if authenticated?
  end

  def create
    if user = User.authenticate_by(email_address: params[:email_address], password: params[:password])
      start_new_session_for(user)
      redirect_to root_path, notice: "Login realizado com sucesso!"
    else
      redirect_to new_session_path, alert: "Email ou senha inválidos."
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, notice: "Logout realizado com sucesso."
  end
end
