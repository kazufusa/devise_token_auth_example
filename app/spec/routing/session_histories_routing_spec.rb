require "rails_helper"

RSpec.describe SessionHistoriesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/session_histories").to route_to("session_histories#index")
    end
  end
end
