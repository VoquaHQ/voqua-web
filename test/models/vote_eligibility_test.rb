require "test_helper"

class VoteEligibilityTest < ActiveSupport::TestCase
  setup do
    @ballot = ballots(:one)
  end

  test "already_voted? returns false when no record exists" do
    assert_not VoteEligibility.already_voted?(@ballot.id, "somehash")
  end

  test "already_voted? returns true when record exists" do
    VoteEligibility.create!(ballot_id: @ballot.id, phone_hash: "abc123")
    assert VoteEligibility.already_voted?(@ballot.id, "abc123")
  end

  test "enforces uniqueness of phone_hash per ballot" do
    VoteEligibility.create!(ballot_id: @ballot.id, phone_hash: "abc123")
    dup = VoteEligibility.new(ballot_id: @ballot.id, phone_hash: "abc123")
    assert_not dup.valid?
  end

  test "same phone_hash is valid for different ballots" do
    ballot2 = ballots(:two)
    VoteEligibility.create!(ballot_id: @ballot.id, phone_hash: "abc123")
    other = VoteEligibility.new(ballot_id: ballot2.id, phone_hash: "abc123")
    assert other.valid?
  end
end
