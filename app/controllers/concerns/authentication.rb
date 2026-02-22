module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?
  end

  private

  def authenticated?
    Current.session.present?
  end

  def require_authentication
    resume_session || request_authentication
  end

  def resume_session
    if session_record = find_session_by_cookie
      Current.session = session_record
    end
  end

  def find_session_by_cookie
    Session.find_by(id: cookies.signed[:session_id])
  end

  def request_authentication
    redirect_to new_session_path, alert: "Você precisa fazer login para acessar esta página."
  end

  def start_new_session_for(user)
    user.sessions.create!(
      ip_address: request.remote_ip,
      user_agent: request.user_agent
    ).tap do |session|
      Current.session = session
      cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
    end
  end

  def terminate_session
    Current.session&.destroy
    cookies.delete(:session_id)
  end
end
