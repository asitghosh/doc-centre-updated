class UpdatesController < ApplicationController
  before_filter :authenticate_see_all_user!
  def index
    @updates = Update.published
  end

  def hide_update
    current_user.hide_update
    render :nothing => true
  end
end