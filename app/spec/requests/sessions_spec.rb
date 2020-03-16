require 'rails_helper'

RSpec.describe "POST /auth/sign_in", type: :request do
  let(:user) { FactoryBot.create(:user) }
  subject{ post user_session_path, params: params; response }

  context "with valid email and password" do
    let(:params) { {email: user.email, password: user.password} }
    it { is_expected.to have_http_status(:success) }
    it { expect(subject.header).to include "access-token", "client", "uid" }
    it do
      expect{ subject; user.reload }.to change { user.sign_in_count }.by(1)
        .and change { user.current_sign_in_at }
        .and change { user.current_sign_in_ip }
        .and change { user.last_sign_in_at }
        .and change { user.last_sign_in_ip }
    end
  end

  context "with invalid password" do
    let(:params) { {email: user.email, password: "a"+user.password} }
    it { is_expected.to have_http_status(:unauthorized) }
  end

  context "with unregistered email" do
    let(:params) { {email: "a"+user.email, password: user.password} }
    it { is_expected.to have_http_status(:unauthorized) }
  end
end

RSpec.describe "DELETE /auth/sign_in", type: :request do
  let(:user) { FactoryBot.create(:user) }
  subject {delete destroy_user_session_path, headers: headers; response }

  context "with singing in" do
    let(:headers) { user.create_new_auth_token }
    it { is_expected.to have_http_status(:success) }
    it { expect(subject.header).not_to include "access-token", "client", "uid" }
  end

  context "without singing in" do
    it { is_expected.to have_http_status(:not_found) }
  end
end
