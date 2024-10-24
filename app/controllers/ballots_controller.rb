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

class BallotsController < ApplicationController
  before_action :authenticate_user!

  def show
    @ballot = Ballot.includes(:questions).find(params[:id])
    @votes = @ballot.votes.find_by(profile: current_user.main_profile)
    if @ballot.private? && !@ballot.invited?(current_user)
      redirect_to root_path, alert: "You are not allowed to view that ballot."
    end
  end

  def submit_votes
    @ballot = Ballot.includes(:questions).find(params[:ballot_id])

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
end
