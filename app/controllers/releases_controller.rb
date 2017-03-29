class ReleasesController < ApplicationController
  include PdfControllerMethods
  include RestrictedPartners

  layout "releases"
  before_filter :get_releases, :only => [:show, :print]

  def index
    @releases = get_all_releases
    set_format_cookie(params) if params[:c] && params[:c] = "y"
    @layout = read_format_cookie(params)
  end


  def show
    respond_to do |format|
      format.html
      #format.pdf  { redirect_to @release.authenticated_s3_pdf_url(current_user) }
      format.pdf  {
        @context = :pdf
        if is_resque_worker?
          html = render_to_string formats: :html, layout: "pdf"
          render inline: @release.prepare_html(html)
        else
          return_pdf(@release)
        end
      }
      # format.pdfhtml { @context = :pdf } if ENV['IS_A_RESQUE_WORKER']
      format.json { render json: @release }
    end
  end

  private

  def get_all_releases
    all_releases = Release.page(params[:page]).includes(:features, :hotfixes, :channel_specific_contents).with_read_marks_for(current_user)
    (current_user and current_user.is_admin? ) ?
      all_releases :
      all_releases.published
  end

  def set_format_cookie(params)
    if params[:view] && params[:view] == "list"
      cookies.signed[:r_format] = "list"
    else
      cookies.signed[:r_format] = "grid"
    end
  end

  def read_format_cookie(params)
    if cookies.signed[:r_format]
      return cookies.signed[:r_format]
    else
      return "grid"
    end
  end

  def get_release(title)
    Release.find("#{title}")
  end

  def get_releases
    @release = get_release(params[:id])
    @subsection_headings     =  @release.subsection_headings
    if current_user
      #@release_features      =  gather_features
      @release_hotfixes      =  gather_hotfixes
      @specific_content      =  sort_by_channel_partner(gather_specific_content)
    else
      @release_features      =  @release.features.public
    end
    show_status_bar(@release)
  end

  def gather_features
    current_user.can_see_all? ?
      @release.features :
      @release.features.public_with_specifics_for(current_user.channel_partner.id)
  end

  def gather_specific_content
    current_user.can_see_all? ?
      @release.channel_specific_contents :
      @release.channel_specific_contents.of(current_user.channel_partner.id)
  end

  def gather_hotfixes
    current_user.can_see_all? ?
      @release.hotfixes :
      @release.hotfixes.public_with_specifics_for(current_user.channel_partner.id)
  end

end
