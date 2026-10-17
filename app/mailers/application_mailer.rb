class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM", "Backsoon <noreply@backsoon.local>")
  layout "mailer"
end
