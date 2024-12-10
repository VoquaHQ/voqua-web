class ApplicationMailer < ActionMailer::Base
  #FIXME: set default from email
  default from: "noreply@voqua.io"
  layout "mailer"
end
