class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken

  protected

  def authenticate_admin!
    unless current_user&.admin
      render_error(401, "Admin unauthorized")
    end
  end

  def render_error(status, message, data = nil)
    response = {
      success: false,
      errors: [message]
    }
    response = response.merge(data) if data
    render json: response, status: status
  end
end
