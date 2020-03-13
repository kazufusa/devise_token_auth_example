class NotificationMailer < ApplicationMailer
  def send_account_locks(resource)
    @resource = resource
    mail(
      subject: "Your #{@resource.name} account has been locked",
      to: @resource.email
    ) do |format|
      format.html
    end
  end

  def send_account_unlocks(resource)
    @resource = resource
    mail(
      subject: "Your #{@resource.name} account has been unlocked",
      to: @resource.email
    ) do |format|
      format.html
    end
  end
end
