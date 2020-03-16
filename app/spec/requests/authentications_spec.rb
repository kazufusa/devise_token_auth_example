require 'rails_helper'

RSpec.shared_examples 'Authentication' do |with_pw, expired|
  before(:each) do
    admin = FactoryBot.create(:user, admin: true)
    headers = admin.create_new_auth_token

    @current_user = FactoryBot.build_stubbed(:user)
    params = {
      email: @current_user.email,
      password: with_pw ? @current_user.password : nil,
      confirm_success_url: "https://testapp.com/registration"
    }
    post(user_registration_path, params: params, headers: headers)
  end

  it "gives you an new user" do
    expect(response).to have_http_status(:success)
  end

  it "gives you an confirmation mail" do
    expect(ActionMailer::Base.deliveries.last).to be_present
    expect(ActionMailer::Base.deliveries.last.to).to contain_exactly @current_user.email
  end

  it "forbids you to login before confirmation and reset password" do
    login
    expect(response).to have_http_status(:unauthorized)
  end

  it "#{expired ? "forbids" : "enables"} you to confirm and login #{expired ? "after a month" : ""}" do
    travel 32.day if expired

    confirmation_link = %r{<a href="http://(.+)">Confirm my account<\/a>}
      .match(ActionMailer::Base.deliveries.last.body.to_s)[1]
    get confirmation_link
    expect(response).to have_http_status(:found)
    unless expired
      expect(response.location).to include "https://testapp.com/registration", "access-token", "client", "uid"
      expect(response.location).not_to include "reset_password_token"
    end

    delete destroy_user_session_path, params: Rack::Utils.parse_query(URI.parse(response.location).query)
    expect(response).to have_http_status(expired == false ? :success : :not_found)

    login
    expect(response).to have_http_status(expired == false ? :success : :unauthorized)
  end if with_pw

  it "#{expired ? "forbids" : "enables"} you to confirm and login #{expired ? "after a month" : ""}" do
    travel 32.day if expired

    confirmation_link = %r{<a href="http://(.+)">Confirm my account<\/a>}
      .match(ActionMailer::Base.deliveries.last.body.to_s)[1]
    get confirmation_link

    expect(response).to have_http_status(:found)
    if expired
      expect(response.location).to include "https://testapp.com/registration", "account_confirmation_success=false"
      expect(response.location).not_to include "access-token", "client", "uid", "reset_password_token"
    else
      expect(response.location).to include "https://testapp.com/registration", "reset_password_token"
      expect(response.location).not_to include "access-token", "client", "uid"
    end

    params = Rack::Utils.parse_query(URI.parse(response.location).query).merge({
      "password"=> "new-password",
      "password_confirmation"=> "new-password",
    })
    patch user_password_path(params)
    expect(response).to have_http_status(expired == false ? :success : :unauthorized)

    login
    expect(response).to have_http_status(:unauthorized)

    login "new-password"
    expect(response).to have_http_status(expired == false ? :success : :unauthorized)
  end unless with_pw
end

RSpec.describe "Sign up with password and confirmation in time" do
  include_examples "Authentication", true, false
end

RSpec.describe "Sign up with password and confirmation expired" do
  include_examples "Authentication", true, true
end

RSpec.describe "Sign up without password and confirmation in time" do
  include_examples "Authentication", false, false
end

RSpec.describe "Sign up without password and confirmation expired" do
  include_examples "Authentication", false, true
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

RSpec.describe 'Whether access is ocurring improperly', type: :request do
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

RSpec.describe "lockable account", type: :request do
  let(:user) { FactoryBot.create(:user) }
  subject(:n) { n.times { post user_session_path, params: invalid_params } }

  context "with 2 times login failure" do
    let(:invalid_params) {{ email: user.email, password: "invalid" }}
    let(:n) { 2 }

    it "increments user failed_attempts" do
      subject
      user.reload
      expect(user.locked_at).to be_nil
      expect(user.failed_attempts).to eq(n)
    end
  end

  context "with 10 times login failure" do
    let(:invalid_params) {{ email: user.email, password: "invalid" }}
    let(:n) { 10 }

    it "makes account locked and notify nothing to user" do
      subject
      user.reload
      expect(user.locked_at).not_to be_nil
      expect(ActionMailer::Base.deliveries.last).not_to be_present
    end

    it "disable user to log in " do
      subject
      expect(response.status).to eq(401)
      expect(response.body).to include \
        "Your account has been locked due to an excessive number of unsuccessful sign in attempts."
    end
  end

end

def login pw=nil
  post user_session_path, params: {
    email: @current_user.email,
    password: pw || @current_user.password,
  }
end
