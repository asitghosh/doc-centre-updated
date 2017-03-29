class HtmlForPdfController  < AbstractController::Base
  include AbstractController::Logger
  include AbstractController::Rendering
  include AbstractController::Layouts
  include AbstractController::Helpers
  include AbstractController::Translation
  include AbstractController::AssetPaths
  include ActionController::UrlFor
  include Rails.application.routes.url_helpers
  include ActionDispatch

  helper ApplicationHelper

  self.view_paths = "app/views"

  def sort_by_channel_partner(contents)
    ofthejedi = {}
    contents.map do |content|
      content.channel_partners.each do |cp|
        ofthejedi[cp.name] ||= []
        ofthejedi[cp.name] << content
      end
    end
    Hash[ofthejedi.sort]
  end

  def show_status_bar(options)
    nil
  end

  def get_releases
    @release = Release.find(@resource_id)
    @subsection_headings     =  @release.subsection_headings
    if @current_user
    #   #@release_features     =  gather_features
      @release_hotfixes      =  gather_hotfixes
      @specific_content      =  sort_by_channel_partner(gather_specific_content)
    else      
      @release_features      =  @release.features.public
    end
    # show_status_bar(@release)
  end

  def gather_features
    @current_user.can_see_all? ? 
      @release.features : 
      @release.features.public_with_specifics_for(@channel_partner_id)
  end

  def gather_specific_content
    @current_user.can_see_all? ?
      @release.channel_specific_contents :
      @release.channel_specific_contents.of(@channel_partner_id)
  end

  def gather_hotfixes
    @current_user.can_see_all? ?
      @release.hotfixes :
      @release.hotfixes.public_with_specifics_for(@channel_partner_id)
  end

  def render(options = {})
    @resource_id        = options[:id]
    @classname          = options[:classname]
    @channel_partner    = options[:channel_partner]
    @channel_partner_id = @channel_partner["id"]
    @current_user = User.new(name: "Temp", channel_partner_id: @channel_partner_id, role_ids: [Role.find_by_name(:channel_admin).id])
    get_releases
    render_to_string template: "#{@classname.downcase.pluralize}/pdf", layout: "pdf"
  end

end