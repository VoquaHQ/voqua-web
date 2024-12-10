class ApplicationMailer < ActionMailer::Base
  #FIXME: set default from email
  default from: "noreply@mailer.voqua.io"
  layout "mailer"
end
