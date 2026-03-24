class PhoneOtp < ApplicationRecord
  belongs_to :ballot

  MAX_ATTEMPTS = 3
  EXPIRY_DURATION = 5.minutes

  validates :phone_hash, presence: true
  validates :code_digest, presence: true
  validates :expires_at, presence: true

  before_validation :set_expiry, on: :create

  def self.find_active(ballot_id, phone_hash)
    where(ballot_id: ballot_id, phone_hash: phone_hash)
      .where("expires_at > ?", Time.current)
      .where("attempts < ?", MAX_ATTEMPTS)
      .first
  end

  def self.recent_for_phone(ballot_id, phone_hash, within: 2.minutes)
    where(ballot_id: ballot_id, phone_hash: phone_hash)
      .where("created_at > ?", within.ago)
      .exists?
  end

  def expired?
    expires_at < Time.current
  end

  def max_attempts_reached?
    attempts >= MAX_ATTEMPTS
  end

  def active?
    !expired? && !max_attempts_reached?
  end

  def verify_code!(code)
    return false unless active?
    if secure_compare(code_digest, self.class.digest_code(code.to_s.strip, phone_hash))
      true
    else
      increment!(:attempts)
      false
    end
  end

  def self.build_for(ballot:, phone_e164:, plain_code:)
    phone_hash = PhoneHashService.call(phone_e164, ballot.id)
    new(
      ballot: ballot,
      phone_hash: phone_hash,
      code_digest: digest_code(plain_code, phone_hash)
    )
  end

  def self.digest_code(code, salt)
    OpenSSL::HMAC.hexdigest("SHA256", salt, code.to_s)
  end

  private

  def set_expiry
    self.expires_at ||= EXPIRY_DURATION.from_now
  end

  def secure_compare(a, b)
    ActiveSupport::SecurityUtils.secure_compare(a.to_s, b.to_s)
  end
end
