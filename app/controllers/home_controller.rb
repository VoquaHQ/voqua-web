class HomeController < ApplicationController
  # The homepage view is cached for 1 hour for non-authenticated users.
  # Logged-in users are immediately redirected to their dashboard,
  # so they never see the cached static landing page.
  def index
    redirect_to my_root_path if current_user
  end
end
