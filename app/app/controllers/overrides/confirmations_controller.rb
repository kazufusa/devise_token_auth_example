module Overrides
  class ConfirmationsController < DeviseTokenAuth::ConfirmationsController
    def show
      super
    rescue ActionController::RoutingError => e
      redirect_header_options = { account_confirmation_success: false, error: e }
      redirect_to_link = DeviseTokenAuth::Url.generate(redirect_url, redirect_header_options)
      redirect_to(redirect_to_link)
    end
  end
end
