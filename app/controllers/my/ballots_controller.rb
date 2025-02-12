class My::BallotsController < My::BaseController
  def index
    @ballots = current_user.main_profile.ballots.includes(profile: :user)
  end

  def new
    @ballot = current_user.main_profile.owned_ballots.build(ends_at: 3.days.from_now)
  end

  def create
    @ballot = current_user.main_profile.owned_ballots.build(ballot_params)
    if @ballot.save
      BallotMembership.create!(ballot: @ballot, profile: current_user.main_profile)
      flash[:success] = "Ballot created successfully."
      redirect_to my_ballot_path(@ballot)
    else
      flash.now[:error] = "There was a problem creating the ballot."
      render :new
    end
  end

  def show
    @ballot = current_user.main_profile.owned_ballots.includes(votes: :profile, invitations: { ballot_membership: :profile }).find_by!(slug: params[:id])
    @question = Question.new
  end

  def edit
    @ballot = current_user.main_profile.owned_ballots.find_by!(slug: params[:id])
  end

  def update
    @ballot = current_user.main_profile.owned_ballots.find_by!(slug: params[:id])
    if @ballot.update(ballot_params)
      redirect_to my_ballot_path(@ballot)
    else
      render :edit
    end
  end

  def destroy
    @ballot = current_user.main_profile.owned_ballots.find_by!(slug: params[:id])
    @ballot.destroy
    flash[:success] = "Ballot deleted."
    redirect_to my_ballots_path
  end

  private

  def ballot_params
    params.require(:ballot).permit(:name, :description, :ends_at, :private)
  end
end
