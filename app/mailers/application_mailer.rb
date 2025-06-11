class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("DEFAULT_FROM_EMAIL", "noreply@bandcalendar.com")
  layout "mailer"
end
