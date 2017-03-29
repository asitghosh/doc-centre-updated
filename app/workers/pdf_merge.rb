class PdfMerge
  include S3Utils
  include PdfGeneratable
  @queue = :merge_pdfs

  attr_accessor :resource, :channel_partner, :queue

  def self.perform(resource_id, resource_class, channel_partner)
    pdf = PdfMerge.new(resource_id, resource_class, channel_partner)
    pdf.create_pdf
  end

end