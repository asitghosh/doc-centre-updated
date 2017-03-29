require 'resque/errors'
require 'resque-retry'

class PdfGenerator
  extend Resque::Plugins::Retry  
  include PdfGeneratable
  
  @queue = :publish_pdfs
  @retry_limit = 3
  
  #@retry_delay = 60 # Retry delay is set in seconds and only works if you run rake resque:scheduler in a separate process

end