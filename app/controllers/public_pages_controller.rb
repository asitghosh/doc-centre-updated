class PublicPagesController < ApplicationController
  #include RestrictedPartners
  #include PdfControllerMethods
  before_filter :get_Apis, :only =>  [:show, :print]

  layout "pdf",               :only => [:print, :print_all]

  def print
  end

  def print_all
    #@Apis = Api.printable.find_all{ |p| p.is_guide? }
  end


  def show
    if params[:path] == ""
      redirect_to action: "index"
    end
    respond_to do |format|
      format.html {
        render "show", :layout => "application_fluid"
      }
      format.pdf  {
        @context = :pdf
        if is_resque_worker?
          html = render_to_string formats: :html, layout: "pdf"
          render inline: @api.prepare_html(html)
        else
          return_pdf(@api)
        end
      }
    end

  end

  def index
    # This won't work as it includes Training & Help & Support links
    # @books = Api.published.roots
    render "index", :layout => false 
  end

  def sort
    respond_to do |format|
      format.json { render :json => api.sort(params[:support_ids].keys, params[:support_ids]) }
    end
  end #end sort

  def framemaker_redirect
    dictionary = Rails.configuration.mm_fm_dictionary
    # check if we have this page stored as an entry itself
    if Api.where("framemaker_page_id = ?", params[:fm_id]).first.present?
      redirect_to Api.where("framemaker_page_id = ?", params[:fm_id]).first.permalink
    else
      # otherwise check the dictionary to see what page contains this name
      containing_page = dictionary[params[:fm_id]].to_s
      raise ActiveRecord::RecordNotFound.new("Not Found") if containing_page.blank?
      if Api.where("framemaker_page_id = ?", containing_page).first.present?
        redirect_to Api.where("framemaker_page_id = ?", containing_page).first.permalink + "##{params[:fm_id]}"
      else
        raise ActiveRecord::RecordNotFound.new("Not Found")
      end
    end
  end

  private

  helper_method :channel_specific_content

  def channel_specific_content(api)

    if current_user
      content = current_user.can_see_all? ?
        api.channel_specific_contents :
        api.channel_specific_contents.of(current_user.channel_partner.id)

      sort_by_channel_partner(content)
    else
      return ""
    end
  end


  def set_sidenav_root(requested_page)
    @root_node = Api.where("permalink = ?", "/" + requested_page.permalink.split("/").reject!(&:empty?)[0,2].join("/")).first

    if current_user && current_user.can_see_all?
      @sidenav_root = @root_node.descendants.arrange(:order => :sortable_order)
    else
      @sidenav_root = @root_node.descendants.arrange(:order => :sortable_order).reject { |page| page.pub_status != "published" }
    end
  end

  def get_Apis(prefix = nil)
    requested_api = Api.find_by_permalink!("/#{params[:path]}")
    # if the request is for the book landing page, stop processing and render book index with the requested resource
    # you can't redirect_to here because it makes an entirely new request and we don't have a route for these pages.
    # TODO: figure out how to route this...
    if requested_api.depth == 0
      @api = requested_api
      @apis = requested_api.descendants.at_depth(1)
      render "book_index", :layout => false and return
    end
    # otherwise compute the redirect_to first live child chain like normal
    if requested_api.redirect_to_first_child
      if requested_api.first_live_child
        return redirect_to requested_api.first_live_child.permalink
      else
        raise ActionController::RoutingError.new('Not Found')
      end
    else
      @api = requested_api
    end

    raise ActionController::RoutingError.new('Not Found') unless @api.published? || ( current_user && current_user.can_see_drafts? )
    @subsection_headings = prep_subsection_headings(@api)
    @channel_specific_content = channel_specific_content(@api)
    set_sidenav_root(@api)
    show_status_bar(@api)
  end

  def prep_subsection_headings(api)
    api.subsection_headings ? JSON.parse(api.subsection_headings) : ""
  end

end
