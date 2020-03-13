require "rails_helper"

RSpec.describe UsersController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/users").to route_to("users#index")
    end

    it "routes to #show" do
      expect(:get => "/users/1").to route_to("users#show", :id => "1")
    end

    it "routes to #destroy via PATCH" do
      expect(:delete => "/users/1").to route_to("users#destroy", :id => "1")
    end

    it "routes to #lock via PATCH" do
      expect(:post => "/users/1/lock").to route_to("users#lock", :id => "1")
    end

    it "routes to #unlock via PATCH" do
      expect(:post => "/users/1/unlock").to route_to("users#unlock", :id => "1")
    end

  end
end
