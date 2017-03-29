#encoding: utf-8
module PdfControllerMethods


  def mock_user

    channel_partner_id  = params[:channel_partner_id]
    resource_class      = params[:resource_class]
    resource_id         = params[:id]
    appdirect_employee  = channel_partner_id.to_i == User.appdirect_id

    user = User.new(:name => "UNIQUE PDF User",
                         :email => "PDFUSER@example.com",
                         :channel_partner_id => channel_partner_id,
                         )
    # if appdirect_employee
    #   def user.can_see_all?
    #     true
    #   end
    # end
    user
  end

  def current_user 
    is_resque_worker? ? mock_user : super
  end

  # def active_user
  #   if is_resque_worker? 
  #     mock_user
  #   elsif user_signed_in? == false
  #     anon_user
  #   else 
  #     current_user
  #   end
  # end

  def anon_user
    channel_partner  = ChannelPartner.where(:subdomain => "ad").first
    user = User.new(:name => "Public PDF User", :email => "publicuser@example.com", :channel_partner_id => channel_partner.id)
    user
  end

  def redirect_pdf_success(resource)
    url = resource.authenticated_s3_pdf_url(current_user)
    if request.xhr?
      render :json => { success: true, url: url}, status: 200
    else
      redirect_to url
    end
  end

  def redirect_pdf_failure(resource)
    if request.xhr?
      render :json => { success: false}, status: 202
    else
      pdf_flash(resource)
      redirect_to resource
    end
  end

  def pdf_flash(resource)
    url   = self.send("#{resource.class.name.underscore}_path", resource.title, format: 'pdf')
    link  = view_context.link_to(t("click_here", scope: :general), url)
    flash_text = t(:generating_flash, :scope => :pdf, href: link).html_safe
    flash[:pdf_generation] = flash_text
  end

  #Regarding dequeue/enqueue
  # When the front-end queues a PDF, the backend has two minutes to create it before the frontend times out.
  # When the state has been "processing" for longer than two minutes, it no longer counts as "processing"
  # If a user elects to retry the download, we dequeue any waiting tasks, and requeue which touches the processing state,
  # giving us another 2 minutes to wait for the PDF to finish.

  def queue_pdf(resource)
    dequeue = Resque.dequeue(PdfGenerator, resource.class.name, resource.id, current_user.channel_partner.id)
    if !resource.processing_pdf_for?(current_user) or dequeue > 0
      Resque.dequeue(PdfGeneratorHighPriority, resource.class.name, resource.id, current_user.channel_partner.id)
      Resque.enqueue(PdfGeneratorHighPriority, resource.class.name, resource.id, current_user.channel_partner.id)
    end
  end

  def return_pdf(resource)   
    if resource.pdf_ready_for?(current_user)
      redirect_pdf_success(resource)
    else
      queue_pdf(resource)
      redirect_pdf_failure(resource)
    end
  end

end
