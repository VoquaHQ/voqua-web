class Voting
  CREDITS_PER_BALLOT = 99

  class VotingError < StandardError; end
  class InvalidQuestionIdsError < VotingError; end
  class DoubleVoteError < VotingError; end
  class TooManyCreditsError < VotingError; end

  def initialize(ballot, questions, votes)
    @ballot = ballot
    @questions = questions
    @votes = votes
  end

  def process!
    question_ids = @questions.map(&:id).sort
    received_question_ids = @votes.keys.map(&:to_i).sort
    if question_ids != received_question_ids
      raise InvalidQuestionIdsError.new
    end

    data = {}
    credits_used = 0

    @votes.each do |question_id_s, answer|
      question_id = question_id_s.to_i

      votes_against = answer[:against].to_i
      votes_for = answer[:for].to_i

      if votes_against > 0 && votes_for > 0
        raise DoubleVoteError.new
      end

      votes_count = votes_against + votes_for
      credits_used += votes_count ** 2

      data[question_id] = {}
      data[question_id][:against] = votes_against
      data[question_id][:for] = votes_for
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
    results = {}

    @votes.each do |vote|
      vote.data.each do |question_id, answer|
        results[question_id] ||= { for: 0, against: 0 }
        results[question_id][:for] += answer["for"]
        results[question_id][:against] += answer["against"]
      end
    end

    results
  end
end

class BallotsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_ballot
  before_action :check_ballot_permissions
  before_action :check_ballot_open, only: [:show, :submit_votes]

  def show
    @votes = @ballot.votes.find_by(profile: current_user.main_profile)
  end

  def results
    @votes = @ballot.votes
    @results = BallotResults.new(@votes).process!
  end

  def submit_votes
    voting = Voting.new(@ballot, @ballot.questions, params[:votes])
    data = voting.process!

    votes = @ballot.votes.find_or_initialize_by(profile: current_user.main_profile)
    votes.data = data

    if votes.save
      redirect_to ballot_path(@ballot), notice: "Votes submitted successfully."
    else
      flash[:error] = "There was a problem submitting your votes"
      redirect_to ballot_path(@ballot)
    end
  rescue Voting::VotingError
    flash[:error] = "Invalid votes"
    redirect_to ballot_path(@ballot)
  end

  private

  def load_ballot
    @ballot = Ballot.includes(:questions).find(params[:id])
  end

  def check_ballot_permissions
    if @ballot.private? && !@ballot.member?(current_user)
      #FIXME: This should be a 404
      redirect_to root_path, alert: "You are not allowed to view that ballot."
    end
  end

  def check_ballot_open
    if @ballot.ends_at < Time.current
      redirect_to results_ballot_path(@ballot)
    end
  end
end
