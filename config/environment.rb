# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
DocCenter::Application.initialize!

Paperclip::Attachment.default_options.merge!(
  :storage => :s3,
  :bucket => ENV['S3_BUCKET'],
  :url => "/system/:class/:attachment/:id/:style/:filename",
  :s3_credentials => {
    :access_key_id => ENV['S3_ACCESS_KEY_ID'],
    :secret_access_key => ENV['S3_SECRET_ACCESS_KEY']
  },
  s3_protocol: 'https'
)

ActionMailer::Base.smtp_settings = {
  :user_name => ENV['SENDGRID_USERNAME'],
  :password => ENV['SENDGRID_PASSWORD'],
  :domain => 'docs.appdirect.com',
  :address => 'smtp.sendgrid.net',
  :port => 587,
  :authentication => :plain,
  :enable_starttls_auto => true
}

OpenID.fetcher_use_env_http_proxy

dictionary = File.read("#{Rails.root}/public/framemaker/Marketplace-Manager/dictionary.json")
data_hash = JSON.parse(dictionary)

Rails.configuration.mm_fm_dictionary = data_hash
