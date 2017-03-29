class PdfDeletion
  @queue = :pdf_deletion

  def self.perform(s3path)
    s3bucket = AWS::S3.new.buckets[ENV['S3_BUCKET']]
    s3pdf = s3bucket.objects[s3path]
    s3pdf.delete
  end
end