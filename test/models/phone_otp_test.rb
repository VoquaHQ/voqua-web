require "test_helper"

class PhoneOtpTest < ActiveSupport::TestCase
  setup do
    @ballot = ballots(:one)
    @ballot.update_columns(phone_verification: true, allowed_country_code: "DE")
    @phone_e164 = "+15555550100"
    @plain_code = "123456"
    @phone_hash = PhoneHashService.call(@phone_e164, @ballot.id)
  end

  test "builds otp with phone_hash and code digest" do
    otp = PhoneOtp.build_for(
      ballot: @ballot,
      phone_e164: @phone_e164,
      plain_code: @plain_code
    )
    otp.save!

    reloaded = PhoneOtp.find(otp.id)
    assert_equal @phone_hash, reloaded.phone_hash
    assert reloaded.code_digest.present?
  end

  test "expires_at is set automatically" do
    otp = PhoneOtp.build_for(
      ballot: @ballot, phone_e164: @phone_e164, plain_code: @plain_code
    )
    otp.save!
    assert otp.expires_at > Time.current
    assert otp.expires_at <= 6.minutes.from_now
  end

  test "active? is true for fresh otp" do
    otp = PhoneOtp.build_for(
      ballot: @ballot, phone_e164: @phone_e164, plain_code: @plain_code
    )
    otp.save!
    assert otp.active?
  end

  test "expired? is true when expires_at is in the past" do
    otp = PhoneOtp.build_for(
      ballot: @ballot, phone_e164: @phone_e164, plain_code: @plain_code
    )
    otp.save!
    otp.update_columns(expires_at: 1.minute.ago)
    assert otp.expired?
    assert_not otp.active?
  end

  test "verify_code! returns true for correct code" do
    otp = PhoneOtp.build_for(
      ballot: @ballot, phone_e164: @phone_e164, plain_code: @plain_code
    )
    otp.save!
    assert otp.verify_code!(@plain_code)
  end

  test "verify_code! returns false for wrong code" do
    otp = PhoneOtp.build_for(
      ballot: @ballot, phone_e164: @phone_e164, plain_code: @plain_code
    )
    otp.save!
    assert_not otp.verify_code!("999999")
  end

  test "verify_code! does not increment attempts on correct code" do
    otp = PhoneOtp.build_for(
      ballot: @ballot, phone_e164: @phone_e164, plain_code: @plain_code
    )
    otp.save!
    otp.verify_code!(@plain_code)
    assert_equal 0, otp.reload.attempts
  end

  test "verify_code! increments attempts on wrong code" do
    otp = PhoneOtp.build_for(
      ballot: @ballot, phone_e164: @phone_e164, plain_code: @plain_code
    )
    otp.save!
    otp.verify_code!("wrong")
    assert_equal 1, otp.reload.attempts
  end

  test "active? is false after MAX_ATTEMPTS reached" do
    otp = PhoneOtp.build_for(
      ballot: @ballot, phone_e164: @phone_e164, plain_code: @plain_code
    )
    otp.save!
    otp.update_columns(attempts: PhoneOtp::MAX_ATTEMPTS)
    assert_not otp.active?
    assert otp.max_attempts_reached?
  end

  test "find_active returns nil for expired otp" do
    otp = PhoneOtp.build_for(
      ballot: @ballot, phone_e164: @phone_e164, plain_code: @plain_code
    )
    otp.save!
    otp.update_columns(expires_at: 1.minute.ago)
    assert_nil PhoneOtp.find_active(@ballot.id, @phone_hash)
  end

  test "find_active returns nil after max attempts" do
    otp = PhoneOtp.build_for(
      ballot: @ballot, phone_e164: @phone_e164, plain_code: @plain_code
    )
    otp.save!
    otp.update_columns(attempts: PhoneOtp::MAX_ATTEMPTS)
    assert_nil PhoneOtp.find_active(@ballot.id, @phone_hash)
  end

  test "recent_for_phone returns true within rate limit window" do
    otp = PhoneOtp.build_for(
      ballot: @ballot, phone_e164: @phone_e164, plain_code: @plain_code
    )
    otp.save!
    assert PhoneOtp.recent_for_phone(@ballot.id, @phone_hash)
  end

  test "recent_for_phone returns false for old records" do
    otp = PhoneOtp.build_for(
      ballot: @ballot, phone_e164: @phone_e164, plain_code: @plain_code
    )
    otp.save!
    otp.update_columns(created_at: 3.minutes.ago)
    assert_not PhoneOtp.recent_for_phone(@ballot.id, @phone_hash)
  end
end
