class NotificationMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notification_mailer.user_notification.subject
  #
  def user_notification(user, admin_notification)
    @user = user
    @admin_notification = admin_notification
    @subject = admin_notification.subject
    @content = admin_notification.content
    @events = admin_notification.events
    @sent_by = admin_notification.sent_by
    
    mail(
      to: user.email,
      subject: @subject,
      from: ENV.fetch("DEFAULT_FROM_EMAIL", "noreply@bandcalendar.com"),
      reply_to: @sent_by.email
    )
  end
end
