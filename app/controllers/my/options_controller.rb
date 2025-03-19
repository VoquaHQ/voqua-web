class My::OptionsController < My::BaseController
  before_action :set_ballot

  def index
    @options = @ballot.options
  end

  def new
    @option = @ballot.options.build
  end

  def create
    @option = @ballot.options.build(option_params)
    if @option.save
      flash[:success] = "Option created successfully."
      redirect_to my_ballot_path(@ballot)
    else
      flash[:error] = "There was a problem creating the option."
      redirect_to my_ballot_path(@ballot), error: "There was a problem creating the option."
    end
  end

  def generate
    b = AI::BallotBuilder.new
    resp = b.generate_options("#{@ballot.name}: #{@ballot.description}")
    BallotOption.transaction do
      resp[:options].each do |option|
        option.ballot = @ballot
        option.save!
      end
    end

    redirect_to my_ballot_path(@ballot), notice: "Options generated successfully."
  end

  # def edit
  #   @option = @ballot.options.find(params[:id])
  # end

  # def update
  #   @option = @ballot.options.find(params[:id])
  #   if @option.update(option_params)
  #     redirect_to my_ballot_options_path(@ballot), notice: "option updated successfully."
  #   else
  #     flash.now[:alert] = "There was a problem updating the option."
  #     render :edit
  #   end
  # end

  def destroy
    @option = @ballot.options.find(params[:id])
    @option.destroy
    flash[:success] = "Option deleted successfully."
    redirect_to my_ballot_path(@ballot)
  end

  private

  def set_ballot
    @ballot = current_user.main_profile.owned_ballots.find_by!(slug: params[:ballot_id])
  end

  def option_params
    params.require(:ballot_option).permit(:title, :description)
  end
end
