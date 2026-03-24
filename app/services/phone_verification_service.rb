class PhoneVerificationService
  class Error < StandardError; end
  class InvalidPhoneError < Error; end
  class WrongCountryError < Error; end
  class RateLimitedError < Error; end
  class InvalidCodeError < Error; end
  class ExpiredCodeError < Error; end
  class AlreadyVotedError < Error; end

  def initialize(ballot)
    @ballot = ballot
  end

  def request_otp(phone_number:)
    phone = Phonelib.parse(phone_number)

    raise InvalidPhoneError, "Phone number is not valid" unless phone.valid?

    unless phone.country == @ballot.allowed_country_code
      raise WrongCountryError, "Phone number must be from #{@ballot.allowed_country_code}"
    end

    phone_e164 = phone.e164
    phone_hash = PhoneHashService.call(phone_e164, @ballot.id)

    if VoteEligibility.already_voted?(@ballot.id, phone_hash)
      raise AlreadyVotedError, "This phone number has already voted on this ballot"
    end

    if PhoneOtp.recent_for_phone(@ballot.id, phone_hash)
      raise RateLimitedError, "Please wait a moment before requesting another code"
    end

    PhoneOtp.where(ballot: @ballot, phone_hash: phone_hash).delete_all

    plain_code = generate_code

    otp = PhoneOtp.build_for(
      ballot: @ballot,
      phone_e164: phone_e164,
      plain_code: plain_code
    )
    otp.save!

    SmsService.send_otp(phone_e164, plain_code)

    phone_hash
  end

  def verify_otp(phone_hash:, code:)
    otp = PhoneOtp.find_active(@ballot.id, phone_hash)

    if otp.nil?
      stale = PhoneOtp.find_by(ballot: @ballot, phone_hash: phone_hash)
      raise ExpiredCodeError, "Code has expired or too many attempts" if stale
      raise InvalidCodeError, "Invalid or expired code"
    end

    unless otp.verify_code!(code)
      raise InvalidCodeError, "Incorrect code"
    end

    if VoteEligibility.already_voted?(@ballot.id, phone_hash)
      otp.destroy
      raise AlreadyVotedError, "This phone number cannot be used for this ballot"
    end

    ActiveRecord::Base.transaction do
      VoteEligibility.create!(ballot_id: @ballot.id, phone_hash: phone_hash)
      otp.destroy
    end

    true
  end

  private

  def generate_code
    rand(100_000..999_999).to_s
  end
end
