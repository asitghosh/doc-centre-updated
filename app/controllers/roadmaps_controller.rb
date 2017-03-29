class RoadmapsController < ApplicationController
  include RestrictedPartners
  before_filter :get_roadmap, :only =>  [:show, :print]
  before_filter :gather_navigation, :only => :show

  def show
  end

  def index
    # redirect to the latest quarter of the most recent year roadmap when someone hits the index
    redirect_to Roadmap.published.first.children.published.first.permalink
  end

  def sort
    respond_to do |format|
      format.json { render :json => Roadmap.sort(params[:page_ids].keys, params[:page_ids]) }
    end
  end #end sort

  def get_roadmap(prefix = nil)
    requested_page = Roadmap.with_read_marks_for(current_user).find_by_permalink!("/roadmaps/#{params[:path]}")
    if requested_page.redirect_to_first_child
      if requested_page.first_live_child
        return redirect_to requested_page.first_live_child.permalink
      else
        raise ActionController::RoutingError.new('Not Found')
      end
    else
      @roadmap = requested_page
    end

    raise ActionController::RoutingError.new('Not Found') if @roadmap.pub_status == "draft" && !current_user.can_see_drafts?
    show_status_bar(@roadmap)
    get_children if @roadmap.is_a_quarter
  end

  def get_children
    @children = @roadmap.children.published
  end

  def gather_navigation
    @navigation = Roadmap.arrange(:order => :sortable_order)
  end
end
