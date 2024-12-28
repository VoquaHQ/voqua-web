class HomeController < ApplicationController
  def index
    redirect_to my_root_path if current_user
  end

  def beta
    redirect_to my_root_path if current_user
  end
end
