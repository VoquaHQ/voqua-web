class Voting
  CREDITS_PER_BALLOT = 99

  class VotingError < StandardError; end
  class InvalidOptionIdsError < VotingError; end
  class DoubleVoteError < VotingError; end
  class TooManyCreditsError < VotingError; end

  def initialize(ballot, options, votes)
    @ballot = ballot
    @options = options
    @votes = votes
  end

  def process!
    option_ids = @options.map(&:id).sort
    received_option_ids = @votes.keys.map(&:to_i).sort
    if option_ids != received_option_ids
      raise InvalidOptionIdsError.new
    end

    data = {}
    credits_used = 0

    @votes.each do |option_id_s, answer|
      option_id = option_id_s.to_i

      votes_against = answer[:against].to_i
      votes_for = answer[:for].to_i

      if votes_against > 0 && votes_for > 0
        raise DoubleVoteError.new
      end

      votes_count = votes_against + votes_for
      credits_used += votes_count ** 2

      data[option_id] = {}
      data[option_id][:against] = votes_against
      data[option_id][:for] = votes_for
    end

    if credits_used > CREDITS_PER_BALLOT
      raise TooManyCreditsError.new
    end

    data
  end
end

class BallotResults
  def initialize(votes)
    @votes = votes
  end

  def process!
    # Group votes by option_id and sum for/against values
    option_totals = {}

    @votes.each do |vote|
      vote.data.each do |option_id, answer|
        qid = option_id.to_i
        option_totals[qid] ||= { for: 0, against: 0 }
        option_totals[qid][:for] += answer["for"].to_i
        option_totals[qid][:against] += answer["against"].to_i
      end
    end

    # Convert to array format and calculate final values
    results = option_totals.map do |option_id, totals|
      {
        option_id: option_id,
        for: totals[:for],
        against: totals[:against],
        value: totals[:for] - totals[:against]
      }
    end

    # Sort by value (highest to lowest)
    results.sort{ |a, b| b[:value] <=> a[:value] }
  end
end

class BallotsController < ApplicationController
  before_action :load_ballot
  before_action :check_ballot_permissions
  before_action :check_ballot_open, only: [:show, :submit_votes, :phone_verification, :request_otp, :otp_verification, :verify_otp]

  def show
    if current_user
      @votes = @ballot.votes.find_by(profile: current_user.main_profile)
    else
      @votes = nil
    end
  end

  def results
    @votes = @ballot.votes
    @votes_count = @votes.size
    @results = BallotResults.new(@votes).process!
  end

  def submit_votes
    @raw_votes = params[:votes]
    voting = Voting.new(@ballot, @ballot.options, @raw_votes)
    data = voting.process!

    if current_user
      votes = @ballot.votes.find_or_initialize_by(profile: current_user.main_profile)
      votes.data = data
      save_votes votes
    elsif @ballot.phone_restricted?
      @vote_data = @raw_votes.to_json
      render :phone_verification
    elsif params[:email].present? && params[:pending_token].present?
      @tmp_votes = Vote.find_by!(pending_token: params[:pending_token])
      raise "token already used" if @tmp_votes.pending_token.nil?
      raise "email already set" if @tmp_votes.pending_email.present?
      @tmp_votes.pending_email = params[:email]
      save_tmp_votes @tmp_votes
    else
      @tmp_votes = Vote.create(ballot: @ballot, pending: true, data: data)
      render :new_tmp_vote
    end
  rescue Voting::VotingError
    flash[:error] = "Invalid votes"
    redirect_to ballot_path(@ballot)
  end

  def phone_verification
    @vote_data = params[:vote_data]
    redirect_to ballot_path(@ballot) if @vote_data.blank?
  end

  def request_otp
    @vote_data = params[:vote_data]
    if @vote_data.blank?
      redirect_to ballot_path(@ballot) and return
    end

    service = PhoneVerificationService.new(@ballot)
    phone_hash = service.request_otp(phone_number: params[:phone_number])
    session[:phone_verification_hash] = phone_hash
    render :otp_verification
  rescue PhoneVerificationService::Error => e
    flash.now[:alert] = e.message
    render :phone_verification
  end

  def otp_verification
    @vote_data = params[:vote_data]
    redirect_to ballot_path(@ballot) if @vote_data.blank?
  end

  def verify_otp
    @vote_data = params[:vote_data]
    phone_hash = session[:phone_verification_hash]
    if @vote_data.blank? || phone_hash.blank?
      redirect_to ballot_path(@ballot) and return
    end

    service = PhoneVerificationService.new(@ballot)
    service.verify_otp(phone_hash: phone_hash, code: params[:otp_code])

    raw_votes = JSON.parse(@vote_data, symbolize_names: true).transform_keys(&:to_s)
    voting = Voting.new(@ballot, @ballot.options, raw_votes)
    data = voting.process!
    Vote.create!(ballot: @ballot, data: data, phone_verified: true)

    session.delete(:phone_verification_hash)
    redirect_to vote_confirmed_ballot_path(@ballot)
  rescue PhoneVerificationService::AlreadyVotedError => e
    session.delete(:phone_verification_hash)
    flash[:alert] = e.message
    redirect_to ballot_path(@ballot)
  rescue PhoneVerificationService::Error => e
    flash.now[:alert] = e.message
    render :otp_verification
  rescue Voting::VotingError
    flash[:error] = "Invalid votes"
    redirect_to ballot_path(@ballot)
  end

  def vote_confirmed
  end

  private

  def save_votes votes
    if votes.save
      flash[:success] = "Votes submitted successfully."
      redirect_to my_root_path
    else
      flash[:error] = "There was a problem submitting your votes"
      redirect_to ballot_path(@ballot)
    end
  end

  def save_tmp_votes tmp_votes
    user = User.find_by(email: params[:email])

    if user.nil?
      user = User.new email: params[:email], main_profile: Profile.new
    end

    user.pending_vote_token = tmp_votes.pending_token

    if user.valid? && tmp_votes.save
      if user.new_record?
        user.save!
      else
        user.send_magic_link
      end
      flash[:success] = "Votes submitted successfully. Please check your email to confirm your votes."
      redirect_to root_path
    else
      render :new_tmp_vote
    end
  end


  def load_ballot
    @ballot = Ballot.includes(:options).find_by(slug: params[:id])
    if @ballot.nil?
      @ballot = Ballot.includes(:options).find(params[:id])
    end
  end

  def check_ballot_permissions
    if @ballot.private? && (current_user.nil? || !@ballot.member?(current_user))
      #FIXME: This should be a 404
      redirect_to root_path
    end
  end

  def check_ballot_open
    if @ballot.ends_at < Time.current
      redirect_to results_ballot_path(@ballot)
    end
  end
end
