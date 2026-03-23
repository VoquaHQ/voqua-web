class PhoneHashService
  def self.call(phone_e164, ballot_id)
    pepper = if Rails.env.production?
      Rails.application.credentials.phone_hash_pepper!
    else
      Rails.application.credentials.phone_hash_pepper.presence ||
        Rails.application.secret_key_base
    end
    OpenSSL::HMAC.hexdigest("SHA256", pepper, "#{phone_e164}:#{ballot_id}")
  end
end
