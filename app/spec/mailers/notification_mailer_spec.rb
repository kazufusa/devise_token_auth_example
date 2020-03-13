require "rails_helper"

RSpec.describe NotificationMailer, type: :mailer do
  let(:user) { FactoryBot.create(:user) }

  it "send lock notification" do
    mail = NotificationMailer.send_account_locks(user).deliver
    expect(ActionMailer::Base.deliveries.last).to be_present
    expect(ActionMailer::Base.deliveries.last.to).to contain_exactly user.email
  end

  it "send unlock notification" do
    mail = NotificationMailer.send_account_unlocks(user).deliver
    expect(ActionMailer::Base.deliveries.last).to be_present
    expect(ActionMailer::Base.deliveries.last.to).to contain_exactly user.email
  end
end
