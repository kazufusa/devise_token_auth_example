require 'rails_helper'

RSpec.describe "POST /auth/sign_in", type: :request do
  let(:user) { FactoryBot.create(:user) }
  subject{ post user_session_path, params: params; response }

  context "with valid email and password" do
    let(:params) { {email: user.email, password: user.password} }
    it { is_expected.to have_http_status(:success) }
    it { expect(subject.header).to include "access-token", "client", "uid" }
    it do
      expect{ subject; user.reload }.to change { user.sign_in_count }.by(1)
        .and change { user.current_sign_in_at }
        .and change { user.current_sign_in_ip }
        .and change { user.last_sign_in_at }
        .and change { user.last_sign_in_ip }
    end
    it { expect{subject}.to change(SessionHistory, :count).by(1) }

    context "with already signed in" do
      before do
        post user_session_path, params: {email: user.email, password: user.password}
      end
      let(:params) { {email: user.email, password: user.password} }
      it { is_expected.to have_http_status(:success) }
      it { expect(subject.header).to include "access-token", "client", "uid" }
      it { expect{subject}.to change(SessionHistory, :count).by(1) }
      it "adds successed log to SessionHistory" do
        subject
        expect(SessionHistory.last.is_failed).to be_falsey
      end
    end

    context "with already signed in and expired" do
      before do
        post user_session_path, params: {email: user.email, password: user.password}
        travel 1.year
      end
      let(:params) { {email: user.email, password: user.password} }
      it { is_expected.to have_http_status(:success) }
      it { expect(subject.header).to include "access-token", "client", "uid" }
      it { expect{subject}.to change(SessionHistory, :count).by(1) }
      it "adds successed log to SessionHistory" do
        subject
        expect(SessionHistory.last.is_failed).to be_falsey
      end
    end
  end

  context "with invalid password" do
    let(:params) { {email: user.email, password: "a"+user.password} }
    it { is_expected.to have_http_status(:unauthorized) }
    it { expect{subject}.to change(SessionHistory, :count).by(1) }
    it "adds failed log to SessionHistory" do
      subject
      expect(SessionHistory.last.is_failed).to be_truthy
    end
  end

  context "with unregistered email" do
    let(:params) { {email: "a"+user.email, password: user.password} }
    it { is_expected.to have_http_status(:unauthorized) }
    it { expect{subject}.not_to change(SessionHistory, :count) }
  end
end

RSpec.describe "DELETE /auth/sign_in", type: :request do
  let(:user) { FactoryBot.create(:user,
                                 current_sign_in_at: 1.year.ago.utc,
                                 current_sign_in_ip: "0.0.0.0",
                                 last_sign_in_at: 1.year.ago.utc,
                                 last_sign_in_ip: "0.0.0.0",
                                ) }
  subject {delete destroy_user_session_path, headers: headers; response }

  context "with singing in" do
    let(:headers) { user.create_new_auth_token }
    it { is_expected.to have_http_status(:success) }
    it { expect(subject.header).not_to include "access-token", "client", "uid" }
  end

  context "without singing in" do
    it { is_expected.to have_http_status(:not_found) }
  end
end
