class SupportsController < ApplicationController

  before_filter :get_supports, :only => :show

  def show
    # @support = Support.find_by_permalink("/" + params[:permalink])
    respond_to do |format|
      format.html {
        render "show", :layout => "application_fluid"
      }
    end
  end

  def index
    # redirect to the latest quarter of the most recent year roadmap when someone hits the index
    # find the support with an ancestry value of nil (which means it's root)
    # and the lowest (min) value of sortable_order
    redirect_to Support.published.roots.order("sortable_order ASC").first.permalink
  end

  def sort
    respond_to do |format|
      format.json { render :json => support.sort(params[:support_ids].keys, params[:support_ids]) }
    end
  end #end sort

  private

  def set_sidenav_root(requested_page)
    @navigation = Page.where("type = ?", "Support").arrange(:order => :sortable_order)
  end

  def get_supports
    requested_support = Support.find_by_permalink!("/help-support/#{params[:permalink]}")
    if requested_support.redirect_to_first_child
      if requested_support.first_live_child
        return redirect_to requested_support.first_live_child.permalink
      else
        raise ActionController::RoutingError.new('Not Found')
      end
    else
      @support = requested_support
    end

    raise ActionController::RoutingError.new('Not Found') unless @support.published?  || ( current_user && current_user.can_see_drafts? )
    @subsection_headings = prep_subsection_headings(@support)
    set_sidenav_root(@support)
    show_status_bar(@support)
  end

  def prep_subsection_headings(support)
    support.subsection_headings ? JSON.parse(support.subsection_headings) : ""
  end

end
