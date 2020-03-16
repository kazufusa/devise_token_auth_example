module Overrides
  class ConfirmationsController < DeviseTokenAuth::ConfirmationsController
    before_action :authenticate_admin!, only: [:create]

    def show
      @resource = resource_class.confirm_by_token(resource_params[:confirmation_token])

      if @resource.errors.empty?
        yield @resource if block_given?

        if @resource.encrypted_password.present?
          redirect_header_options = { account_confirmation_success: true }
          token = @resource.create_token
          @resource.save!
          redirect_headers = build_redirect_headers(token.token,
                                                    token.client,
                                                    redirect_header_options)
          redirect_to_link = @resource.build_auth_url(redirect_url, redirect_headers)
          redirect_to(redirect_to_link)
        else
          reset_password_token = set_reset_password_token @resource
          redirect_headers = {
            account_confirmation_success: true,
            reset_password_token: reset_password_token,
          }
          redirect_to_link = DeviseTokenAuth::Url.generate(redirect_url, redirect_headers)
          redirect_to(redirect_to_link)
        end
      else
        redirect_header_options = { account_confirmation_success: false, error: "Not Found" }
        redirect_to_link = DeviseTokenAuth::Url.generate(redirect_url, redirect_header_options)
        redirect_to(redirect_to_link)
      end
    end

    private

    # TODO: :reek:FeatureEnvy :reek:UtilityFunction
    def set_reset_password_token(resource)
      raw, enc = Devise.token_generator.generate(resource.class, :reset_password_token)
      resource.reset_password_token   = enc
      resource.reset_password_sent_at = Time.now.utc
      resource.save!(validate: false)
      raw
    end
  end
end
