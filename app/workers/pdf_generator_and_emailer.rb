require 'resque/errors'
require 'resque-retry'

class PdfGeneratorAndEmailer
  extend Resque::Plugins::Retry
  include PdfGeneratable

  @queue = :publish_then_email_pdfs
  @retry_limit = 3

  def self.after_perform_then_email(resource_class, resource_id, channel_partner_id, options = {})
    puts options
    if options["list"].blank?
      puts "no list to look up"
      return false
    end
  	mailing_list = MailingList.find_by_title(options["list"])
    puts "queing mailing list: #{mailing_list.title}"
  	mailing_list.send_notification(resource_class, resource_id, channel_partner_id, options)
  end

  #@retry_delay = 60 # Retry delay is set in seconds and only works if you run rake resque:scheduler in a separate process

end
