require "test_helper"
require "minitest/mock"

class PhoneVerificationServiceTest < ActiveSupport::TestCase
  setup do
    @ballot = ballots(:one)
    @ballot.update_columns(
      phone_verification: true,
      allowed_country_code: "DE",
      ends_at: 1.week.from_now
    )
    @service = PhoneVerificationService.new(@ballot)
    @german_phone = "+4915100000000"
    @vote_data = { "1" => { "for" => 1, "against" => 0 } }
  end

  # --- request_otp ---

  test "request_otp sends SMS and creates PhoneOtp for valid german phone" do
    SmsService.stub(:send_otp, true) do
      assert_difference "PhoneOtp.count", 1 do
        phone_hash = @service.request_otp(phone_number: @german_phone)
        assert phone_hash.present?
      end
    end
  end

  test "request_otp returns phone_hash" do
    SmsService.stub(:send_otp, true) do
      phone_hash = @service.request_otp(phone_number: @german_phone)
      expected = PhoneHashService.call(@german_phone, @ballot.id)
      assert_equal expected, phone_hash
    end
  end

  test "request_otp raises InvalidPhoneError for invalid phone" do
    SmsService.stub(:send_otp, true) do
      assert_raises(PhoneVerificationService::InvalidPhoneError) do
        @service.request_otp(phone_number: "not-a-phone")
      end
    end
  end

  test "request_otp raises WrongCountryError for phone from wrong country" do
    SmsService.stub(:send_otp, true) do
      assert_raises(PhoneVerificationService::WrongCountryError) do
        @service.request_otp(phone_number: "+14155552671")
      end
    end
  end

  test "request_otp raises RateLimitedError when recent otp exists" do
    SmsService.stub(:send_otp, true) do
      @service.request_otp(phone_number: @german_phone)

      assert_raises(PhoneVerificationService::RateLimitedError) do
        @service.request_otp(phone_number: @german_phone)
      end
    end
  end

  test "request_otp raises AlreadyVotedError when phone already voted" do
    phone_hash = PhoneHashService.call(@german_phone, @ballot.id)
    VoteEligibility.create!(ballot_id: @ballot.id, phone_hash: phone_hash)

    SmsService.stub(:send_otp, ->(_p, _c) { raise "SMS should not be sent" }) do
      assert_raises(PhoneVerificationService::AlreadyVotedError) do
        @service.request_otp(phone_number: @german_phone)
      end
    end
  end

  # --- verify_otp ---

  test "verify_otp creates vote_eligibility on correct code" do
    plain_code = nil
    SmsService.stub(:send_otp, ->(phone, code) { plain_code = code; true }) do
      @service.request_otp(phone_number: @german_phone)
    end

    phone_hash = PhoneHashService.call(@german_phone, @ballot.id)

    assert_difference "VoteEligibility.count", 1 do
      @service.verify_otp(phone_hash: phone_hash, code: plain_code)
    end
  end

  test "verify_otp destroys phone_otp on success" do
    plain_code = nil
    SmsService.stub(:send_otp, ->(phone, code) { plain_code = code; true }) do
      @service.request_otp(phone_number: @german_phone)
    end

    phone_hash = PhoneHashService.call(@german_phone, @ballot.id)
    @service.verify_otp(phone_hash: phone_hash, code: plain_code)

    assert_equal 0, PhoneOtp.where(ballot: @ballot, phone_hash: phone_hash).count
  end

  test "verify_otp raises InvalidCodeError for wrong code" do
    SmsService.stub(:send_otp, true) do
      @service.request_otp(phone_number: @german_phone)
    end

    phone_hash = PhoneHashService.call(@german_phone, @ballot.id)

    assert_raises(PhoneVerificationService::InvalidCodeError) do
      @service.verify_otp(phone_hash: phone_hash, code: "000000")
    end
  end

  test "verify_otp raises AlreadyVotedError on race condition" do
    plain_code = nil
    SmsService.stub(:send_otp, ->(phone, code) { plain_code = code; true }) do
      @service.request_otp(phone_number: @german_phone)
    end

    phone_hash = PhoneHashService.call(@german_phone, @ballot.id)
    # Simulate race: eligibility created between OTP request and verify
    VoteEligibility.create!(ballot_id: @ballot.id, phone_hash: phone_hash)

    assert_raises(PhoneVerificationService::AlreadyVotedError) do
      @service.verify_otp(phone_hash: phone_hash, code: plain_code)
    end
  end

  test "verify_otp raises InvalidCodeError when no OTP exists" do
    phone_hash = PhoneHashService.call(@german_phone, @ballot.id)

    assert_raises(PhoneVerificationService::InvalidCodeError) do
      @service.verify_otp(phone_hash: phone_hash, code: "123456")
    end
  end

  test "vote_eligibility has no link to votes" do
    plain_code = nil
    SmsService.stub(:send_otp, ->(phone, code) { plain_code = code; true }) do
      @service.request_otp(phone_number: @german_phone)
    end

    phone_hash = PhoneHashService.call(@german_phone, @ballot.id)
    @service.verify_otp(phone_hash: phone_hash, code: plain_code)

    eligibility = VoteEligibility.last
    assert_nil eligibility.attributes["vote_id"]
    assert_nil eligibility.attributes["profile_id"]
  end
end
