# encoding: UTF-8
module Pdfable
  extend ActiveSupport::Concern

  included do
    #setting up individual callbacks because (https://github.com/rails/rails/issues/988) is not in our version of Rails yet.

    after_create :generate_pdf
    after_commit :generate_pdf, on: :update
  end

  def pdf_path(current_user=nil, channel_partner_path=nil)
    channel_partner_path  ||= ( current_user and current_user.channel_partner) ?
                              current_user.channel_partner.name : "public"
    class_path              = self.class.to_s.pluralize

    s3path = "pdf/#{channel_partner_path}/#{class_path}/#{filename}".pathsafe
  end

  def filename
    "AppDirect #{self.class.name} #{self.title}.pdf"
  end

  def s3_bucket
    @s3_bucket ||= AWS::S3.new.buckets[ENV['S3_BUCKET']]
  end

  def s3_object(current_user)
    object = s3_bucket.objects[pdf_path(current_user)]
  end

  def authenticated_s3_pdf_url(current_user=nil)
    return secure_url = s3_object(current_user).url_for(:get, {  :expires => 10.minutes.from_now,
                                                :secure => true,
                                                :response_content_disposition => "attachment; filename=\"#{filename}\"",
                                                :response_content_type => "Content-Type: application/octet-stream"
                                              }).to_s
  end # end pdf

  def processing_pdf_for?(current_user)
    options = {task: "pdf", status: "processing", channel_partner_id: current_user.channel_partner.id}
    !!(channel_specific_states.where(options).first.updated_at >= 2.minutes.ago if channel_specific_states.where(options).first.present?)
  end

  def pdf_exists_for?(current_user)
    s3_object(current_user).exists?
  end

  def pdf_ready_for?(current_user)
    !processing_pdf_for?(current_user) and pdf_exists_for?(current_user)
  end

  def prepare_html(html)
    doc = Nokogiri::HTML.parse(html)

    nodes = doc.css '.spy_this'
    nodes.each do |node|
      node_html             = node.to_html
      headline_text         = node.css('.section_separator').first.present? ? node.css('.section_separator').first.clone.text : "Document"
      headline_continued    = " — #{headline_text} Continued — "

      w = "<table class='table_wrapper'>"
      w << "<caption style=\"prince-caption-page: following\">"
      w << headline_continued
      w << "</caption><tr><td>"
      w << node_html
      w << "</tr></td></table>"
      node.replace(Nokogiri.make(w))
    end

    doc.to_html
  end

  def generate_pdf
    #print "preparing PDF for #{self.class.to_s} #{self.title} -- I am printable? #{self.printable?}"
    # if current_user.can_see_all?
    #   ChannelParnter.all.each do |channel_partner_id|
    #     Resque.enqueue(PdfGenerator, self.class.name, self.id, channel_partner_id)
    #   end
    # end
    if self.printable?
      ChannelPartner.pluck(:id).each do |channel_partner_id|
        Resque.enqueue(PdfGenerator, self.class.name, self.id, channel_partner_id)
      end
    end
  end

  # def delete_pdf
  #   ChannelPartner.all.each do |channel_partner|
  #     Resque.enqueue(PdfDeletion, pdf_path(nil, channel_partner.name))
  #   end
  # end


end
