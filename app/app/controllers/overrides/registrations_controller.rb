module Overrides
  class RegistrationsController < DeviseTokenAuth::RegistrationsController
    private

    def account_update_params
      params.permit(:name)
    end
  end
end
