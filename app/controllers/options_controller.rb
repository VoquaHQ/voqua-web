class OptionsController < ApplicationController
  before_action :set_ballot
  before_action :set_option, only: [:update, :destroy]

  def create
    @option = @ballot.options.new(option_params)

    if @option.save
      redirect_to @ballot, notice: 'Option was successfully added.'
    else
      render :new
    end
  end

  def new
    @option = @ballot.options.new
  end

  def update
    if @option.update(option_params)
      redirect_to @ballot, notice: 'Option was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @option.destroy
    redirect_to @ballot, notice: 'Option was successfully removed.'
  end

  private

  def set_ballot
    @ballot = Ballot.find(params[:ballot_id])
  end

  def set_option
    @option = @ballot.options.find(params[:id])
  end

  def option_params
    params.require(:option).permit(:title, :description)
  end
end
