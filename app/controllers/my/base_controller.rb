class My::BaseController < ApplicationController
  before_action :authenticate_user!

  layout "my"
end
