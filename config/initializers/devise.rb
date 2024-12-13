# frozen_string_literal: true

Devise.setup do |config|
  # Email configuration
  config.mailer_sender = 'Voqua <notifications@mailer.voqua.io>'
  
  require 'devise/orm/active_record'

  # Authentication configuration
  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]
  config.skip_session_storage = [:http_auth]
  config.stretches = Rails.env.test? ? 1 : 12
  
  # Confirmable configuration
  config.confirm_within = 24.hours
  config.reconfirmable = true
  
  # Recoverable configuration
  config.reset_password_within = 6.hours
  config.sign_in_after_reset_password = false
  
  # Validatable configuration
  config.password_length = 8..128
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/
  
  # Security settings
  config.expire_all_remember_me_on_sign_out = true
  config.responder.error_status = :unprocessable_entity
  config.responder.redirect_status = :see_other
  
  # Sign out configuration
  config.sign_out_via = :delete
end
