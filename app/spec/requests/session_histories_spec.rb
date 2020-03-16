require 'rails_helper'

RSpec.describe "SessionHistories", type: :request do
  let(:admin) { FactoryBot.create(:user, admin: true) }
  subject { get session_histories_path, headers: headers; response }

  context "with signing up as an administrator" do
    let(:headers) { admin.create_new_auth_token }
    describe "GET /session_histories" do
      it { is_expected.to have_http_status(:ok) }
    end
  end

  context "without signing up as an administrator" do
    describe "GET /session_histories" do
      it { is_expected.to have_http_status(:unauthorized) }
    end
  end
end
