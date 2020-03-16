module Overrides
  class SessionsController < DeviseTokenAuth::SessionsController
    before_action :old_resource, :only => :create
    after_action :log_to_history, :only => :create

    private

    def old_resource
      field = (resource_params.keys.map(&:to_sym) & resource_class.authentication_keys).first
      @old_resource = nil
      if field
        q_value = get_case_insensitive_field_from_resource_params(field)

        @old_resource = find_resource(field, q_value)
      end
    end

    def log_to_history
      if @old_resource.present? && @resource.present?
        if (@resource.tokens.keys - @old_resource.tokens.keys).size > 0
          SessionHistory.create(
            name: @resource.name,
            ip: request.remote_ip,
            is_failed: false,
          )
        else
          SessionHistory.create(
            name: @resource.name,
            ip: request.remote_ip,
            is_failed: true,
          )
        end
      end
    end

    def failed_login?
      (options = env["warden.options"]) && options[:action] == "unauthenticated"
    end 
  end
end
