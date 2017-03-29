if Rails.env.devstaging? #modovate
  ENV['ELASTICSEARCH_URL'] = ENV['BONSAI_AMBER_URL']
elsif Rails.env.production?
  ENV['ELASTICSEARCH_URL'] = ENV['BONSAI_PURPLE_URL']
else
  ENV['ELASTICSEARCH_URL'] = ENV['BONSAI_URL']
end