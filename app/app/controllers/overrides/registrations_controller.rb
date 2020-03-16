module Overrides
  class RegistrationsController < DeviseTokenAuth::RegistrationsController
    before_action :authenticate_admin!, only: :create

    def destroy
      render_error(404, "method not found")
    end

    private

    def account_update_params
      params.permit(:name)
    end
  end
end
