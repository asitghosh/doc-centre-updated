class ApplicationController < ActionController::Base
  protect_from_forgery
  layout :layout_by_resource
  before_filter :superadmin_only_mode, :authorized_doc_center_user, unless: :is_resque_worker?


  rescue_from ActionController::RoutingError, :with => :not_found
  rescue_from AbstractController::ActionNotFound, :with => :not_found
  rescue_from ActiveRecord::RecordNotFound, :with => :not_found
  rescue_from CanCan::AccessDenied, :with => :access_denied

  helper_method :main_title, :get_marketplace_url


  def not_found(exception)
    #raise ActionController::RoutingError.new('Not Found')
    @message = exception.message
    @special_class = "fourohfour"
    respond_to do |format|
      format.html { render :template => 'application/not_found', :status => :not_found, :layout => "application" }
      format.xml  { head :not_found }
      format.any  { head :not_found }
    end
  end

  def is_resque_worker?
    ENV["IS_A_RESQUE_WORKER"] == "true"
  end

  def is_not_resque_worker?
    !is_resque_worker?
  end

  def access_denied
    flash[:warning] = "You don't have permission to do that. Contact an admin if you think this is an error."
    redirect_to admin_root_path
  end

  def subdomain
    @subdomain ||= request.subdomains.first || 'docs'
  end

  def current_channel_partner
    
    @current_channel_partner ||= ChannelPartner.where(subdomain: subdomain).first

  end

  def setup_openid_address
    open_id = current_channel_partner
    if open_id
      session['openid_url'] = open_id.open_id_address
    end
  end

  def partner_name
    @partner_name ||= current_channel_partner.try(:name)
  end

  def main_title
    @main_title ||= partner_name ? "#{partner_name} Documentation Center" : "AppDirect Documentation Center"
  end

  def authorized_doc_center_user
    if subdomain != "docs"
      #setup_openid_address
      authenticate_user!
      unless current_user.is_authorized?
        render_403
      end
    end
  end

  def authenticate_active_admin_user!
    authenticate_user!
    unless current_user.is_admin?
      flash[:alert] = "Unauthorized Access!"
      redirect_to root_path
    end
  end

  def authenticate_see_all_user!

    authenticate_user!
    unless current_user.can_see_all?
      flash[:alert] = "Unauthorized Access!"
      redirect_to root_path
    end
  end

  def render_403
    render :file => "#{Rails.root}/public/403", :status => 403, :layout => false
  end

  def sort_by_channel_partner(contents)
    ofthejedi = {}
    contents.map do |content|
      if content.whitelist == true or content.whitelist.nil?
        # content was whitelisted, add it to each channel partner that's included
        content.channel_partners.each do |cp|
          ofthejedi[cp.name] ||= []
          ofthejedi[cp.name] << content
        end
      else
        # content was blacklisted, add it to everyone but those included
        ChannelPartner.all.each do |cp|
          ofthejedi[cp.name] ||= []
          ofthejedi[cp.name] << content unless (content.channel_partner_ids.include? cp.id or ofthejedi[cp.name].include? content)
        end
      end
    end

    # since we add every channel partner to the array, there's a chance some of them are empty.
    # drop those or we get empty headings
    ofthejedi.reject! do |i|
      ofthejedi[i].empty?
    end

    Hash[ofthejedi.sort]
  end

  def show_status_bar(resource)
    return false unless current_user && current_user.is_admin?
    if resource.published?
      flash.now[:notice] = message_for('Published.', resource)
    else
      flash.now[:warning] = message_for('Draft Version.',resource)
    end
  end

  def message_for(text, resource)
    "<span class='flash-icon'>!</span> #{text} #{view_context.link_to('Edit Page', send("edit_admin_#{resource.class.to_s.parameterize(sep = '_')}_path", resource), class: 'icon-write edit')}".html_safe
  end

  def mark_as_read
    klass = params[:klass]
    if klass == "User Guide"
      klass = "Page"
    end
    klass = klass.camelize.constantize
    id = params[:id]
    resource = klass.where("id = ?", id).first
    # Resque.enqueue(MarkAsRead, klass, klass.id, current_user.id)
    resource.mark_as_read! :for => current_user
    if resource.unread?(current_user) == false
      timestamp = resource.read_mark(current_user).timestamp.strftime("%B %d, %Y")
      render :json => { success: true, resource: resource, timestamp: timestamp, status: 200 }
      # render :json => { success: false, resource: resource, status: 202}

    else
      render :json => { success: false, resource: resource, status: 202}
    end
  end

  def toggle_superadmin_only_mode
    render :json => { status: 403 } unless current_user.has_role?(:superadmin)
    db_setting = AppSettings.find_by_key("superadmin_only_mode")
    if db_setting.value == "false"
      db_setting.update_column("value", "true")
    else
      db_setting.update_column("value", "false")
    end

    redirect_to admin_root_path
  end

  protected

  def layout_by_resource
    if devise_controller?
      "login"
    else
      "application"
    end
  end

  def superadmin_only_mode
    db_setting = AppSettings.find_by_key("superadmin_only_mode")
    # if the site is off, and we're not trying to login, and there is a current_user, and the user is NOT an admin
    if db_setting.value == "true" && controller_name != 'sessions' && current_user && !current_user.can_see_all? && !current_user.is_impersonating?
      # render instead of redirect so people can refresh.
        render 'public/maintenance', :layout => "login", :formats => [:html]
    end
    # set flash on every page for admins
    if db_setting.value == "true" && current_user && ( current_user.can_see_all? || current_user.is_impersonating? )
      flash[:warning] = "The Documentation Center is in Maintenance Mode. Public Access is denied. Please stand by."
    end
  end



end
