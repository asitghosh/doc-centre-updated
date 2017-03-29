class FeaturesController < ApplicationController
  layout 'releases'
  def index
    if current_user.is_admin?
      return redirect_to Feature.shown.first unless Feature.shown.empty?
    else
      return redirect_to Feature.public_with_specifics_for(current_user.channel_partner.id).first unless Feature.public_with_specifics_for(current_user.channel_partner.id).empty?
    end
    # if everything was empty, render the index view with an empty features array
    # this will trigger the no features to show message
    @features = []
  end
  
  def show
    @feature = Feature.find(params[:id])
    test_access_level unless current_user.can_see_all?
    @feature_nav = gather_navigation
    show_status_bar(@feature)

    Resque.enqueue(MarkAsRead, "Feature", @feature.id, current_user.id)

  end

  private

  def test_access_level        
    unless @feature.channel_partners.pluck(:id).empty?
      raise ActionController::RoutingError.new('Not Found') unless @feature.channel_partners.pluck(:id).include?(current_user.channel_partner.id) 
    end
  end

  def gather_navigation
    if current_user.can_see_all?
      Feature.shown
    else
      Feature.public_with_specifics_for(current_user.channel_partner.id)
    end
  end

end