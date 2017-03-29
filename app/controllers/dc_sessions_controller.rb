class DcSessionsController < Devise::SessionsController
  def new

    @current_channel_partner ||= ChannelPartner.where(subdomain: request.subdomains.first).first
    if subdomain != "docs" && @current_channel_partner.blank?
      raise ActionController::RoutingError.new('Not Found')
    end
    super
  end

  def login_proxy
    u = params[:user]
    render :file => "#{Rails.root}/public/no_user", :status => 403, :layout => false and return if u.blank?

    user = User.where("email = ?", params[:user][:email]).first
    if user
      subdomain = user.channel_partner.subdomain
      redirect_to user_omniauth_authorize_url(:appdirect, subdomain: "#{subdomain}.docs")
    else
      render :file => "#{Rails.root}/public/no_user", :status => 403, :layout => false and return
    end
  end


end
