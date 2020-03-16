require 'rails_helper'

RSpec.describe "GET /auth/confirmation", type: :request do
  let(:params) { {
    confirmation_token: user.confirmation_token,
    redirect_url: "http://frontend.com",
  } }

  subject { get user_confirmation_path, params: params; response }

  context "with not confirmed user" do
    let(:user) { FactoryBot.create( :user,
      confirmed_at: nil,
      confirmation_token: Devise.friendly_token,
      confirmation_sent_at: Time.now.utc,
    ) }

    it { is_expected.to have_http_status(:found) }

    it "redirects to url with access token" do
      params = Rack::Utils.parse_query(URI.parse(subject.location).query)
      expect(params).to include "access-token", "client_id", "uid"
    end

    it "makes user confirmed" do
      subject
      expect{ user.reload }.to change { user.confirmed_at }.from(nil)
    end
  end

  context "with already confirmed user" do
    let(:user) { FactoryBot.create(:user) }
    it { is_expected.to have_http_status(:found) }
    it "redirects to url with access token" do
      params = Rack::Utils.parse_query(URI.parse(subject.location).query)
      expect(params).to eq({
        "account_confirmation_success" => "false", "error" => "Not Found"
      })
    end
  end
end

RSpec.describe "POST /auth/confirmation", type: :request do
  let(:params) { {
    email: user.email,
  } }

  subject { post user_confirmation_path, params: params; response }

  context "with existing user" do
    let(:user) { FactoryBot.create(:user) }

    it { is_expected.to have_http_status(:ok) }

    it "sets values of user confirmation_token and confirmation_sent_at" do
      subject
      expect{user.reload}.to change { user.confirmation_token }.from(nil)
        .and change { user.confirmation_sent_at }.from(nil)
    end

    it "sends user a confirmation mail with a link including confirmation_token" do
      subject
      expect(ActionMailer::Base.deliveries.last).to be_present
      expect(ActionMailer::Base.deliveries.last.to).to contain_exactly user.email

      link = %r{<a href="http://(.+)">Confirm my account<\/a>}
        .match(ActionMailer::Base.deliveries.last.body.to_s)[1]
      expect(Rack::Utils.parse_query(URI.parse(link).query)).to include "confirmation_token"
    end
  end

  context "with not existing user" do
    let(:user) { FactoryBot.build(:user) }
    it { is_expected.to have_http_status(:not_found) }
    it "sends no mail" do
      subject
      expect(ActionMailer::Base.deliveries).to be_empty
    end
  end
end
