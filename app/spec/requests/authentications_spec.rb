require 'rails_helper'

describe 'Sign up', type: :request do
  describe "POST /auth" do
    subject { post(user_registration_path, params: params) }
    let(:params) { FactoryBot.attributes_for(:user) }
    it "gives you an new user" do
      subject
      expect(response.has_header?('access-token')).to eq(true)
      expect(response).to have_http_status(:success)

      res = JSON.parse(response.body)
      expect(res["status"]).to eq("success")
      expect(res["data"]["id"]).to eq(User.last.id)
      expect(res["data"]["email"]).to eq(User.last.email)
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
