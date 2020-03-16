require 'rails_helper'

RSpec.describe "GET /auth/validate_token", type: :request do
  let(:user) { FactoryBot.create(:user) }
  subject { get auth_validate_token_path, headers: headers; response }

  context "with sign in" do
    let(:headers) { user.create_new_auth_token }

    it { is_expected.to have_http_status(:ok) }
  end

  context "without sign in" do
    let(:headers) { { "access-token": "hogehoge", "uid": "fugafuga", "client": "piyopiyo" } }
    it { is_expected.to have_http_status(:unauthorized) }
  end
end

