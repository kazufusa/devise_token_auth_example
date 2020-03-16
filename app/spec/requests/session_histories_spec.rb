require 'rails_helper'

RSpec.describe "SessionHistories", type: :request do
  describe "GET /session_histories" do
    it "works! (now write some real specs)" do
      get session_histories_path
      expect(response).to have_http_status(200)
    end
  end
end
