module RestrictedPartners
  extend ActiveSupport::Concern

  included do
    before_filter :check_partner_permissions
  end

  def check_partner_permissions
    #404 for anonymous guests
    raise ActionController::RoutingError.new('Not Found') unless current_user
    #403 for restricted channel partners
    render_403 unless current_user && current_user.channel_partner.send("able_to_see_#{determine_controller_action}?") or is_resque_worker?
  end

  def determine_controller_action
    requested_controller = controller_name
    requested_action = action_name
    requested_controller = "user_guides" if requested_controller == "pages"

    return requested_controller
  end

end
