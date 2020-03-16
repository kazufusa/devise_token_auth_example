module Overrides
  class PasswordsController < DeviseTokenAuth::PasswordsController
    before_action :authenticate_admin!, only: [:create]
  end
end

