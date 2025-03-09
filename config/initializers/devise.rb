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

  config.parent_mailer = "ApplicationMailer"

  # ==> Configuration for :magic_link_authenticatable

  # Need to use a custom Devise mailer in order to send magic links.
  # If you're already using a custom mailer just have it inherit from
  # Devise::Passwordless::Mailer instead of Devise::Mailer
  # config.mailer = "Devise::Passwordless::Mailer"
  config.mailer = "Devise::Passwordless::Mailer"
  config.passwordless_tokenizer = "SignedGlobalIDTokenizer"


  # Which algorithm to use for tokenizing magic links. See README for descriptions
  config.passwordless_tokenizer = "SignedGlobalIDTokenizer"

  # Time period after a magic login link is sent out that it will be valid for.
  # config.passwordless_login_within = 20.minutes

  # The secret key used to generate passwordless login tokens. The default value
  # is nil, which means defer to Devise's `secret_key` config value. Changing this
  # key will render invalid all existing passwordless login tokens. You can
  # generate your own secret value with e.g. `rake secret`
  # config.passwordless_secret_key = nil

  # When using the :trackable module and MessageEncryptorTokenizer, set to true to
  # consider magic link tokens generated before the user's current sign in time to
  # be expired. In other words, each time you sign in, all existing magic links
  # will be considered invalid.
  # config.passwordless_expire_old_tokens_on_sign_in = false
  #
  config.omniauth :google_oauth2, ENV['VOQUA_GOOGLE_OAUTH_CLIENT_ID'], ENV['VOQUA_GOOGLE_OAUTH_CLIENT_SECRET']
  config.omniauth :entra_id, client_id: ENV['VOQUA_MICROSOFT_CLIENT_ID'], client_secret: ENV['VOQUA_MICROSOFT_CLIENT_SECRET'],
    scope: 'openid email profile'

end
