class PagesController < ApplicationController
  include RestrictedPartners
  include PdfControllerMethods
  before_filter :set_sidenav_root
  before_filter :get_pages, :only =>  [:show, :print]

  layout "pdf",:only =>             [:print, :print_all]

  def index
  end

  def print
  end

  def print_all
    @pages = Page.printable.find_all{ |p| p.is_guide? }
  end

  def show
    respond_to do |format|
      format.html
      format.pdf  {
        @context = :pdf
        if is_resque_worker?
          html = render_to_string formats: :html, layout: "pdf"
          render inline: @page.prepare_html(html)
        else
          return_pdf(@page)
        end
      }
    end
  end

  def sort
    respond_to do |format|
      format.json { render :json => Page.sort(params[:page_ids].keys, params[:page_ids]) }
    end
  end #end sort

  private

  helper_method :channel_specific_content

  def channel_specific_content(page)
    content = current_user.can_see_all? ?
      page.channel_specific_contents :
      page.channel_specific_contents.of(current_user.channel_partner.id)

    sort_by_channel_partner(content)
  end

  def get_pages(prefix = nil)

    requested_page = Page.where("type = ? OR type IS NULL", "Manual").find_by_permalink!("/manuals/#{prefix}#{params[:path]}")
    if requested_page.redirect_to_first_child
      if requested_page.first_live_child
        return redirect_to requested_page.first_live_child.permalink
      else
        raise ActionController::RoutingError.new('Not Found')
      end
    else
      @page = requested_page
    end

    raise ActionController::RoutingError.new('Not Found') if @page.pub_status == "draft" && !current_user.can_see_drafts?

    @subsection_headings = prep_subsection_headings(@page)
    @channel_specific_content = channel_specific_content(@page)
    show_status_bar(@page)
  end

  def prep_subsection_headings(page)
    page.subsection_headings ? JSON.parse(page.subsection_headings) : ""
  end

  def set_sidenav_root(root_page = "manuals")
    @navigation = Page.where("type = ?", "Manual").arrange(:order => :sortable_order)
  end


end
