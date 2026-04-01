class My::QuestionsController < My::BaseController
  before_action :find_question, only: [:show, :edit, :update, :destroy, :try_answer]

  def index
    @questions = current_user.main_profile.questions.order(created_at: :desc)
  end

  def new
    @question = current_user.main_profile.questions.build
  end

  def create
    @question = current_user.main_profile.questions.build(question_params)
    if @question.save
      flash[:success] = "Question created."
      redirect_to my_question_path(@question)
    else
      flash.now[:error] = "There was a problem creating the question."
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @question.update(question_params)
      redirect_to my_question_path(@question), notice: "Question updated."
    else
      render :edit
    end
  end

  def destroy
    @question.destroy
    flash[:success] = "Question deleted."
    redirect_to my_questions_path
  end

  def try_answer
    draft = @question.dup
    draft.body = params[:body] if params[:body].present?
    draft.prompt = params[:prompt] if params[:prompt].present?

    service = InterviewerService.new(draft)
    @follow_up = service.generate_follow_up(params[:answer])
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to edit_my_question_path(@question) }
    end
  rescue MistralService::ApiError => e
    @error = e.message
    respond_to do |format|
      format.turbo_stream
      format.html do
        flash[:error] = @error
        redirect_to edit_my_question_path(@question)
      end
    end
  end

  private

  def find_question
    @question = current_user.main_profile.questions.find_by!(uuid: params[:id])
  end

  def question_params
    params.require(:question).permit(:body, :prompt)
  end
end
