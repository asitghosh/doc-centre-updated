class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController  
  skip_before_filter :verify_authenticity_token, :only => [:appdirect]
  skip_before_filter :authorized_doc_center_user  

  def appdirect
    subdomain = request.subdomains.first

    @user = User.find_for_open_id(env["omniauth.auth"], subdomain, current_user )
    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :name => @user.channel_partner.name
      sign_in_and_redirect @user, :event => :authentication
    end
  end
end