require 'rails_helper'

RSpec.describe "POST /auth/password", type: :request do
  let(:admin) { FactoryBot.create(:user, admin: true) }
  let(:user) { FactoryBot.create(:user) }
  let(:newpw) { "new-password" }
  let(:params) {{email: user.email, redirect_url: "https://test"}}
  subject{ post user_password_path, params: params, headers: headers; response }

  context "with signing up as an administrator" do
    let(:headers) { admin.create_new_auth_token }

    it { is_expected.to have_http_status(:ok) }

    it 'sends a mail which has the link including reset_password_token' do
      subject
      expect(ActionMailer::Base.deliveries.last).to be_present
      expect(ActionMailer::Base.deliveries.last.to).to contain_exactly user.email

      link = %r{<a href="http://(.+)">Change my password<\/a>} .match(ActionMailer::Base.deliveries.last.body.to_s)[1]
      expect(Rack::Utils.parse_query(URI.parse(link).query)).to include "reset_password_token"
    end

    it 'sends a mail which has the link including reset_password_token and enables you to change password' do
      subject
      link = %r{<a href="http://(.+)">Change my password<\/a>} .match(ActionMailer::Base.deliveries.last.body.to_s)[1]

      put user_password_path, params: {"password"=> newpw, "password_confirmation"=> newpw }
        .merge(Rack::Utils.parse_query(URI.parse(link).query))
      expect(response).to have_http_status(:ok)

      post user_session_path, params: { email: user.email, password: newpw }
      expect(response).to have_http_status(:ok)
    end
  end

  context "without signing up as an administrator" do
    it { is_expected.to have_http_status(:unauthorized) }
  end
end

RSpec.describe "PUT /auth/password", type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:newpw) { "new-password" }
  let(:params) {{ "password"=> newpw, "password_confirmation"=> newpw }}
  subject { put user_password_path, params: params, headers: headers; response }

  context "with sign in" do
    let(:headers) { user.create_new_auth_token }

    it { is_expected.to have_http_status(:ok) }

    it 'makes your password changed and enables you to login with new pssword' do
      subject

      post user_session_path, params: { email: user.email, password: newpw }
      expect(response).to have_http_status(:ok)
    end
  end

  context "without sign in" do
    it { is_expected.to have_http_status(:unauthorized) }
  end
end

RSpec.describe "PATCH /auth/password", type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:newpw) { "new-password" }
  let(:params) {{ "password"=> newpw, "password_confirmation"=> newpw }}
  subject { patch user_password_path, params: params, headers: headers; response }

  context "with sign in" do
    let(:headers) { user.create_new_auth_token }

    it { is_expected.to have_http_status(:ok) }

    it 'makes your password changed and enables you to login with new pssword' do
      subject

      post user_session_path, params: { email: user.email, password: newpw }
      expect(response).to have_http_status(:ok)
    end
  end

  context "without sign in" do
    it { is_expected.to have_http_status(:unauthorized) }
  end
end

