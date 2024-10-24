class ApplicationMailer < ActionMailer::Base
  #FIXME: set default from email
  default from: "from@example.com"
  layout "mailer"
end
