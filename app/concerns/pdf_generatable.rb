module PdfGeneratable
  extend ActiveSupport::Concern
  include S3Utils

  included do
    attr_accessor :resource_class, :resource_id, :channel_partner_id, :queue
  end

  module ClassMethods

    def perform(resource_class, resource_id, channel_partner_id, options = {})
      pdf = PdfGenerator.new(resource_class, resource_id, channel_partner_id)
      pdf.create_pdf
    rescue Resque::TermException
      # Resque.enqueue(PdfGenerator, resource_class, resource_id, channel_partner_id)
    end

    def after_enqueue_mark_processing(resource_class, resource_id, channel_partner_id, options = {})
      pdf = PdfGenerator.new(resource_class, resource_id, channel_partner_id)
      pdf.mark_as("processing")
    end

    def after_perform_mark_complete(resource_class, resource_id, channel_partner_id, options = {})
      pdf = PdfGenerator.new(resource_class, resource_id, channel_partner_id)
      pdf.mark_as("complete")
    end

    def on_failure(e, resource_class, resource_id, channel_partner_id, options = {})
      pdf = PdfGenerator.new(resource_class, resource_id, channel_partner_id)
      puts e
      pdf.mark_as("failure")
    end
  end


  SLEEP_TIME = 5
  TWO_MINUTES = 120
  def pretty_time; Time.now.strftime("%I:%M:%S %p"); end
  def print_status(status = {}); puts "#{pretty_time} - Status: #{status['status']}";end

  def initialize(resource_class, resource_id, channel_partner_id)
    @resource_class     = resource_class
    @resource_id        = resource_id
    @channel_partner_id = channel_partner_id
    @resource           = resource_class.camelize.constantize.find_by_id(resource_id)
    #TODO: Catch failure if unable to find the resource
    @channel_partner = ChannelPartner.find(channel_partner_id)
    FileUtils.mkpath(temp_dir) #We now have tmp paths that mirror those on Amazon, as such we need to make sure those directories exist before putting PDFs into them
  end

  def setup_app
    @app      = ActionDispatch::Integration::Session.new(Rails.application)
    @app.host = "#{@channel_partner.subdomain}.docs.lvh.me:3000"
  end

  def get_html
    setup_app
    @params   = { resource_class: @resource_class, channel_partner_id: @channel_partner_id }
    if @resource.has_attribute?(:permalink)
      @app.get_via_redirect("#{@resource.permalink}.pdf", @params)
    else
      @app.get_via_redirect(@app.send("#{@resource_class.underscore}_path", @resource.slug, format: "pdf"), @params)
    end
    @app.response.body
  end

  def doc_options
    options = {
      :name             => filename,
      :document_type    => "pdf",
      :test             => ! Rails.env.production?,
      :strict           => "none", #Turns off DocRapter's HTML validator which chokes on HTML5 tags.
      :javascript       => false,
      :async            => true,
      :document_content => get_html
    }
  end

  def state_options
    opts = {
      task: "pdf",
      channel_partner_id: @channel_partner_id,
      channel_specific_state_type: @resource_class,
      channel_specific_state_id:   @resource_id
    }
  end

  def mark_as(state="processing")
    #puts "marking state as #{state}"
    ChannelSpecificState.mark(state_options, state)
  end

  def doc_task
    @doc_task ||= DocRaptor.create(doc_options)
  end

  def doc_status
    DocRaptor.status(doc_task["status_id"])
  end

  # def print_status
  #   status = {'status' => "Queued generation for #{channel_partner_name} with DocRapter"}
  #   print_status(status)
  # end

  def create_pdf
    timeout_time = Time.now + TWO_MINUTES

    while !(['completed','failed'].include? doc_status['status']) && Time.now <= timeout_time
      sleep SLEEP_TIME
      print_status(doc_status['status'])
    end

    if doc_status['status'] == 'completed'
      download_and_save_pdf
    end

    if doc_status['status'] == 'failed'
      #puts "marking state as doc_raptor_failure"
      mark_as("failed")
    end
  end

  def download_and_save_pdf
    file = DocRaptor.download(doc_status['download_key'])
    File.open(temp_file, "w+b") do |f|
      f.write file.response.body
    end

    puts "#{pretty_time} - File downloaded to #{temp_file(:pdf)}"
    key = save_to_s3({file: temp_file})
  end
end
