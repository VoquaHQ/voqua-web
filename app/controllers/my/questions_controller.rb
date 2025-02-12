class My::QuestionsController < My::BaseController
  before_action :set_ballot

  def index
    @questions = @ballot.questions
  end

  def new
    @question = @ballot.questions.build
  end

  def create
    @question = @ballot.questions.build(question_params)
    if @question.save
      flash[:success] = "Option created successfully."
      redirect_to my_ballot_path(@ballot)
    else
      flash[:error] = "There was a problem creating the option."
      redirect_to my_ballot_path(@ballot), error: "There was a problem creating the option."
    end
  end

  # def edit
  #   @question = @ballot.questions.find(params[:id])
  # end

  # def update
  #   @question = @ballot.questions.find(params[:id])
  #   if @question.update(question_params)
  #     redirect_to my_ballot_questions_path(@ballot), notice: "Question updated successfully."
  #   else
  #     flash.now[:alert] = "There was a problem updating the question."
  #     render :edit
  #   end
  # end

  def destroy
    @question = @ballot.questions.find(params[:id])
    @question.destroy
    flash[:success] = "Option deleted successfully."
    redirect_to my_ballot_path(@ballot)
  end

  private

  def set_ballot
    @ballot = current_user.main_profile.owned_ballots.find_by!(slug: params[:ballot_id])
  end

  def question_params
    params.require(:question).permit(:title, :description)
  end
end
