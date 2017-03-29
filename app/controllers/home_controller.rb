class HomeController < ApplicationController
  include HomeHelper
  def index
    if current_user
      # stuff for authenticated users.
      @current_release = Release.current_release
      @cr_has_content ||= @current_release.any_content_for?(current_user) if @current_release
      # @welcome = current_user.quickstart
      if current_user.channel_partner
        @support_links = get_links.find_all { |l| l.link_type == "support" }
        @general_links = get_links.find_all { |l| l.link_type == "links" }
      end
      @welcome = current_user.quickstart
    else
      redirect_to "/help"
      #redirect_to "/developer"
    end
  end

  def changes
    date = params[:date]
    @updates = organize_response(get_recent_changes(date))
    respond_to do |format|
      format.json { render :json => @updates }
    end
  end

  private

  def organize_response(updates)
    ofthejedi = []
    updates.each do |update|
      next if update.class.to_s == "Release" && !update.any_content_for?(current_user)
      ud = {
        :title => update.friendly_title,
        :section => update.headline,
        :klass => sort_pages(update),
        :section_link => generate_section_link(update),
        :last_update => update.updated_at.strftime("%B %d, %Y"),
        :published_on => update.created_at.strftime("%B %d, %Y"),
        :action => format_update_item(update),
        :id => update.id,
        :status => update.unread?(current_user) ? "Unread" : "Read",
        :link => generate_link(update),
        :merged => check_feature(update),
        :read_on => read_date(update)
      }

      ofthejedi << ud
    end
    return ofthejedi
  end

  def read_date(update)
    if update.read_marks.empty?
      return ""
    else
      update.read_marks.first.timestamp.strftime("%B %d, %Y")
    end
  end

  def check_feature(update)
    return false unless update.class.to_s == "Feature"
    if update.release != nil
      return "Merged into #{update.release.title}"
    else
      false
    end
  end

  def generate_section_link(update)

    if update.class.to_s == "Roadmap"
      return "/roadmaps"
    elsif update.class.to_s == "Manual"
      return "/manuals"
    elsif update.class.to_s == "Api"
      return update.root.permalink
    else
      return view_context.url_for(update.class)
    end
  end

  def generate_link(update)
    update.respond_to?('permalink') ?
      update.permalink :
      view_context.url_for(update)
  end

  def sort_pages(update)
    s = update.class.to_s
    return s unless s == "Page"
    if update.is_guide?
      return "Guide"
    else
      return "Page"
    end
  end

  def get_links
    @links ||= current_user.channel_partner.custom_links
  end

  def get_recent_changes(time)
    time = time || current_user.last_sign_in_at
    (  release_changes(time) +
       guide_changes(time) +
       roadmap_changes(time)

      #Feature.created_or_updated_since(time, current_user)
    ).sort { |a,b| a.updated_at <=> b.updated_at }
  end

  def guide_changes(time)
    if current_user.channel_partner.able_to_see_user_guides?
      Manual.created_or_updated_since(time, current_user)
    else
      []
    end
  end

  def roadmap_changes(time)
    if current_user.channel_partner.able_to_see_roadmaps?
      # skip the root nodes since the years don't have any actual content
      Roadmap.from_depth(1).created_or_updated_since(time, current_user)
    else
      []
    end
  end

  def release_changes(time)
    if current_user.channel_partner.able_to_see_releases?
      Release.created_or_updated_since(time, current_user)
    else
      []
    end
  end

end
