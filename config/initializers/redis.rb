rails_root = Rails.root || File.dirname(__FILE__) + '/../..'
rails_env = Rails.env || 'development'

# puts rails_root.to_s + '/config/resque.yml'
resque_config = YAML.load_file(rails_root.to_s + '/config/resque.yml')
uri = URI.parse( ENV["REDISTOGO_URL"] ? ENV["REDISTOGO_URL"] : resque_config[rails_env]) 
REDIS_WORKER = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password, :thread_safe => true)