require 'rails_helper'

RSpec.shared_examples 'Users' do |user|
  before(:each) do
    @users = FactoryBot.create_list(:user, 10)
  end
  let(:headers) { user&.create_new_auth_token }
  let(:status) { user&.admin ? :success : :unauthorized}
  let(:status_delete) { user&.admin ? :no_content : :unauthorized}

  it "makes GET /users #{user&.admin ? "":" not "} work" do
    get users_path, headers: headers
    expect(response).to have_http_status(status)
  end

  it "makes GET /users/:id #{user&.admin ? "":" not "} work" do
    get user_path(@users.first.id), headers: headers
    expect(response).to have_http_status(status)
  end

  it "makes DELETE /users/:id #{user&.admin ? "":" not "} work" do
    delete user_path(@users.first.id), headers: headers
    expect(response).to have_http_status(status_delete)
  end

  it "makes POST /users/:id/lock #{user&.admin ? "":" not "} work" do
    post lock_user_path(@users.first.id), headers: headers
    expect(response).to have_http_status(status)
  end

  it "makes POST /users/:id/unlock #{user&.admin ? "":" not "} work" do
    post unlock_user_path(@users.first.id), headers: headers
    expect(response).to have_http_status(status)
  end
end

RSpec.describe "Users" do
  after(:all) do
    User.delete_all
  end

  describe "with admin login" do
    include_examples "Users", FactoryBot.create(:user, admin: true)
  end

  describe "with user login" do
    include_examples "Users", FactoryBot.create(:user)
  end

  describe "without login" do
    include_examples "Users", nil
  end
end
