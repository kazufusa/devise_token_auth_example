require 'rails_helper'

RSpec.describe "POST /auth/sign_in without sign in", type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:params) { {email: user.email, password: user.password} }
  subject{ post user_session_path, params: params; response }

  it { is_expected.to have_http_status(:success) }
  it { expect(subject.header).to include "access-token", "client", "uid" }
end

RSpec.describe "DELETE /auth/sign_in with sign in", type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:headers) { user.create_new_auth_token }
  subject {delete destroy_user_session_path, headers: headers; response }

  it { is_expected.to have_http_status(:success) }
  it { expect(subject.header).not_to include "access-token", "client", "uid" }
end
