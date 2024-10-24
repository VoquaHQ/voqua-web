class My::BallotsController < My::BaseController
  def index
    @ballots = current_user.ballots
  end

  def new
    @ballot = current_user.main_profile.ballots.build
  end

  def create
    @ballot = current_user.main_profile.ballots.build(ballot_params)
    if @ballot.save
      redirect_to my_ballot_path(@ballot), notice: "Ballot created."
    else
      flash.now[:alert] = "There was a problem creating the ballot."
      render :new
    end
  end

  def show
    @ballot = current_user.ballots.includes(invitations: :accepted_by).find(params[:id])
    @question = Question.new
  end

  def edit
    @ballot = current_user.ballots.find(params[:id])
  end

  def update
    @ballot = current_user.ballots.find(params[:id])
    if @ballot.update(ballot_params)
      redirect_to my_ballots_path, notice: "Ballot updated."
    else
      render :edit
    end
  end

  def destroy
    @ballot = current_user.ballots.find(params[:id])
    @ballot.destroy
    redirect_to my_ballots_path, notice: "Ballot deleted."
  end

  private

  def ballot_params
    params.require(:ballot).permit(:name, :description, :ends_at, :private)
  end
end
