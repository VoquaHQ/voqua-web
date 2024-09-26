class BallotsController < ApplicationController
  before_action :set_ballot, only: [:show, :edit, :update, :destroy, :vote, :results]
  before_action :authenticate_user!, except: [:show, :results]

  def index
    @ballots = current_user.ballots
  end

  def show
    @user_votes = current_user.votes.where(option: @ballot.options).pluck(:option_id, :credits, :in_favor).map { |id, credits, in_favor| [id, { credits: credits, in_favor: in_favor }] }.to_h if user_signed_in?
  end

  def new
    @ballot = Ballot.new
  end

  def create
    @ballot = current_user.ballots.new(ballot_params)

    if @ballot.save
      redirect_to @ballot, notice: 'Ballot was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @ballot.update(ballot_params)
      redirect_to @ballot, notice: 'Ballot was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @ballot.destroy
    redirect_to ballots_url, notice: 'Ballot was successfully destroyed.'
  end

  def vote
    ActiveRecord::Base.transaction do
      params[:votes].each do |option_id, vote_data|
        option = @ballot.options.find(option_id)
        vote = option.votes.find_or_initialize_by(user: current_user)
        vote.credits = vote_data[:credits].to_i
        vote.in_favor = vote_data[:in_favor] == 'true'
        vote.save!
      end
    end
    redirect_to @ballot, notice: 'Your votes were recorded.'
  rescue ActiveRecord::RecordInvalid
    redirect_to @ballot, alert: 'There was an error recording your votes.'
  end

  def results
    @options = @ballot.options.includes(:votes).order(created_at: :asc)
  end

  private

  def set_ballot
    @ballot = Ballot.find(params[:id])
  end

  def ballot_params
    params.require(:ballot).permit(:title, :description, :deadline)
  end
end
