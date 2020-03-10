require 'rails_helper'

describe 'Sign up with password', type: :request do
  before(:each) do
    @current_user = FactoryBot.build_stubbed(:user)
    params = {
      email: @current_user.email,
      password: @current_user.password,
      confirm_success_url: "https://testapp.com/registration"
    }
    post(user_registration_path, params: params)
  end

  context "and confirm and sign in" do
    it "gives you an new user" do
      expect(response).to have_http_status(:success)
    end

    it "gives you an confirmation mail" do
      expect(ActionMailer::Base.deliveries.last).to be_present
      expect(ActionMailer::Base.deliveries.last.to).to contain_exactly @current_user.email
    end

    it "enable you to confirm" do
      confirmation_link = %r{<a href="http://(.+)">Confirm my account<\/a>}
        .match(ActionMailer::Base.deliveries.last.body.to_s)[1]
      get confirmation_link
      expect(response.status).to eq(302)
    end

    it "enable you to confirm and login" do
      confirmation_link = %r{<a href="http://(.+)">Confirm my account<\/a>}
        .match(ActionMailer::Base.deliveries.last.body.to_s)[1]
      get confirmation_link
      expect(response.status).to eq(302)
      login
      expect(response.status).to eq(200)
    end
  end

  context "and confimation_token is expired" do
    it "gives you an new user" do
      expect(response).to have_http_status(:success)
    end

    it "gives you an confirmation mail" do
      expect(ActionMailer::Base.deliveries.last).to be_present
      expect(ActionMailer::Base.deliveries.last.to).to contain_exactly @current_user.email
    end

    it "forbid you to confirm  after a month" do
      travel 32.day

      confirmation_link = %r{<a href="http://(.+)">Confirm my account<\/a>}
        .match(ActionMailer::Base.deliveries.last.body.to_s)[1]
      get confirmation_link
      expect(response.status).to eq(302)
    end

    it "forbid you to confirm and login after a month" do
      travel 32.day

      confirmation_link = %r{<a href="http://(.+)">Confirm my account<\/a>}
        .match(ActionMailer::Base.deliveries.last.body.to_s)[1]
      get confirmation_link
      expect(response.status).to eq(302)
      login
      expect(response.status).to eq(401)
    end
  end
end

RSpec.describe 'Whether access is ocurring properly', type: :request do
  before(:each) do
    @current_user = FactoryBot.create(:user)
  end

  context 'general authentication via API, ' do
    it 'gives you an authentication code if you are an existing user and you satisfy the password' do
      login
      expect(response.has_header?('access-token')).to eq(true)
    end

    it 'gives you a status 200 on signing in ' do
      login
      expect(response.status).to eq(200)
    end
  end
end

describe 'Whether access is ocurring improperly', type: :request do
  before(:each) do
    @current_user = FactoryBot.create(:user)
  end

  context 'general authentication via API, ' do
    it 'gives you no authentication code if you do not satisfy the password' do
      login "invalidpw"
      expect(response.has_header?('access-token')).to eq(false)
    end

    it 'gives you a status 401 on failing to sign in ' do
      login "invalidpw"
      expect(response.status).to eq(401)
    end
  end
end

def login pw=nil
  post user_session_path,
    params:  { email: @current_user.email, password: pw || @current_user.password }.to_json,
    headers: { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
end
