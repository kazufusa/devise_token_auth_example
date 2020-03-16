require 'rails_helper'

RSpec.describe "PATCH /auth/sign_up", type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:params) { {name: "updated name" } }
  subject{ patch user_registration_path, params: params, headers: headers; response }

  context "with sign in" do
    let(:headers) { user.create_new_auth_token }
    it { is_expected.to have_http_status(:success) }
    it "makes your name changed" do
      subject
      user.reload
      expect(user.name).to eq("updated name")
    end
  end

  context "without sign in" do
    it { is_expected.to have_http_status(:not_found) }
  end
end

RSpec.describe "PUT /auth/sign_up", type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:params) { {name: "updated name" } }
  subject{ put user_registration_path, params: params, headers: headers; response }

  context "with sign in" do
    let(:headers) { user.create_new_auth_token }
    it { is_expected.to have_http_status(:success) }
    it "makes your name changed" do
      subject
      user.reload
      expect(user.name).to eq("updated name")
    end
  end

  context "without sign in" do
    it { is_expected.to have_http_status(:not_found) }
  end
end

RSpec.describe "DELETE /auth/sign_up", type: :request do
  let(:user) { FactoryBot.create(:user) }
  subject{ delete user_registration_path, headers: headers; response }

  context "with signing in as user" do
    it { is_expected.to have_http_status(:not_found) }
  end

  context "without signing in as user" do
    it { is_expected.to have_http_status(:not_found) }
  end
end

RSpec.describe "POST /auth/sign_up", type: :request do
  let(:admin) { FactoryBot.create(:user, admin: true) }
  let(:user) { FactoryBot.build_stubbed(:user) }
  let(:params) {{ email: user.email, confirm_success_url: "https://frontend.com/" }}
  subject{ post user_registration_path, params: params, headers: headers; response }

  context "with singing up as an administrator" do
    let(:headers) { admin.create_new_auth_token }

    it { is_expected.to have_http_status(:success) }

    it "sends user a email with a link including a confirmation_token" do
      subject
      expect(ActionMailer::Base.deliveries.last).to be_present
      expect(ActionMailer::Base.deliveries.last.to).to contain_exactly user.email

      link = %r{<a href="http://(.+)">Confirm my account<\/a>}
        .match(ActionMailer::Base.deliveries.last.body.to_s)[1]
      expect(Rack::Utils.parse_query(URI.parse(link).query)).to include "confirmation_token"
    end
  end

  context "without singing up as an administrator" do
    it { is_expected.to have_http_status(:unauthorized) }
  end
end

