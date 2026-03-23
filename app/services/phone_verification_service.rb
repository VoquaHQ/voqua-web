class PhoneVerificationService
  class Error < StandardError; end
  class InvalidPhoneError < Error; end
  class WrongCountryError < Error; end
  class RateLimitedError < Error; end
  class InvalidCodeError < Error; end
  class ExpiredCodeError < Error; end
  class AlreadyVotedError < Error; end
  class VoteNotFoundError < Error; end

  def initialize(ballot)
    @ballot = ballot
  end

  def request_otp(pending_token:, phone_number:)
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

    # Delete any stale OTPs for this pending vote
    PhoneOtp.where(ballot: @ballot, pending_token: pending_token).delete_all

    plain_code = generate_code

    otp = PhoneOtp.build_for(
      ballot: @ballot,
      pending_token: pending_token,
      phone_e164: phone_e164,
      plain_code: plain_code
    )
    otp.save!

    SmsService.send_otp(phone_e164, plain_code)

    true
  end

  def verify_otp(pending_token:, code:)
    vote = Vote.find_by(pending_token: pending_token, ballot: @ballot)
    raise VoteNotFoundError, "Vote session not found" unless vote

    otp = PhoneOtp.find_active(@ballot.id, pending_token)

    if otp.nil?
      stale = PhoneOtp.find_by(ballot: @ballot, pending_token: pending_token)
      raise ExpiredCodeError, "Code has expired or too many attempts" if stale
      raise InvalidCodeError, "Invalid or expired code"
    end

    unless otp.verify_code!(code)
      raise InvalidCodeError, "Incorrect code"
    end

    phone_hash = otp.phone_hash

    if VoteEligibility.already_voted?(@ballot.id, phone_hash)
      otp.destroy
      vote.destroy
      raise AlreadyVotedError, "This phone number has already voted on this ballot"
    end

    ActiveRecord::Base.transaction do
      vote.update!(pending: false, pending_token: nil, phone_verified: true)
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
