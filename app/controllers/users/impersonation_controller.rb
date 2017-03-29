class Users::ImpersonationController < ActionController::Base
  before_filter :can_impersonate

  def impersonate
    id = params[:id]
    current_user.update_column(:impersonation_id, id)
    respond_to do |format|
      format.json { render :json => "true" }
    end
  end

  def unimpersonate
    current_user.update_column(:impersonation_id, nil)
    respond_to do |format|
      format.json { render :json => "true" }
    end
  end

  protected

  def can_impersonate
    # if this returns false execution stops.
    current_user.can_see_all?
  end
end