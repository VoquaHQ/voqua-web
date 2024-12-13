class ApplicationMailer < ActionMailer::Base
  default from: "Voqua <notifications@mailer.voqua.io>"
  layout "mailer"
end
