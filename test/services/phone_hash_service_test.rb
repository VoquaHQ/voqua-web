require "test_helper"

class PhoneHashServiceTest < ActiveSupport::TestCase
  test "returns a hex string" do
    result = PhoneHashService.call("+491234567890", 1)
    assert_match(/\A[0-9a-f]{64}\z/, result)
  end

  test "same inputs produce same hash" do
    a = PhoneHashService.call("+491234567890", 1)
    b = PhoneHashService.call("+491234567890", 1)
    assert_equal a, b
  end

  test "different phone produces different hash" do
    a = PhoneHashService.call("+491234567890", 1)
    b = PhoneHashService.call("+491234567891", 1)
    assert_not_equal a, b
  end

  test "same phone different ballot produces different hash" do
    a = PhoneHashService.call("+491234567890", 1)
    b = PhoneHashService.call("+491234567890", 2)
    assert_not_equal a, b
  end
end
