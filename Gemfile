source 'https://rubygems.org'
ruby '1.9.3'
gem 'rails', '~> 3.2.18' # I don't need to explain this.
gem 'unicorn' # server
gem 'pg' # database
gem "devise" # user auth flow
gem "omniauth", "~> 1.1" # authentication
gem "omniauth-openid", "~> 1.0.1" # adds openid to omniauth
gem "omniauth-appdirect", :git => 'https://github.com/ad-dc/omniauth-appdirect.git' # our openid strategy
gem "ruby-openid", :git => "https://github.com/ad-dc/ruby-openid" #openid for ruby, changed env vars in our fork
gem 'memcachier' # used for asset pipeline caching
gem "dalli", "~> 2.6.2" # easy communication with memcach stores
gem 'openid_active_record_store', :git => "https://github.com/ad-dc/openid_active_record_store.git" # store session data in database
gem "unread", :git => "https://github.com/ad-dc/unread" # fuels the read/unread feature
gem "cancan", ">= 1.6.8" # user permissions
gem 'activeadmin', "~> 0.6.3" # backend
#gem 'activeadmin-cancan' # backend user permissions
gem 'jquery-rails', '~> 2.3.0' # jQuery
gem 'paperclip' # File uploads
#gem 'rich', :path => "/Volumes/Not_Mum/Dropbox/Projects/rich"
gem 'rich', :git => 'https://github.com/ad-dc/rich.git' # WYSIWYG
gem 'friendly_id' # easy nice slugs for resources
gem 'ancestry' # page hierarchy
gem "rolify", ">= 3.2.0" # user roles
gem "figaro", ">= 0.5.0" # easy env var store
gem "diffy" # used with paper_trail on resources that are being tracked
gem "paper_trail" # tracks versions of resources
gem "json", ">= 1.7.7" # json
gem "aws-sdk" #Used by rich
gem "resque" # delayed job stuff with redis
gem "resque-retry" # Retries failed jobs n number of times
gem "simple-navigation", ">= 4.0.0" # used for header/footer navigation
gem "truncate_html" # used on releases to truncate text for rbox/etc
gem 'hirefire-resource' # dynamic heroku dyno management to keep costs down, used with hirefire.io
gem 'airbrake', "= 3.1.8" # errbit
gem 'color-tools' # used to generate 50% of channel color for some elements
gem 'nokogiri', ">= 1.6" # used to parse input and generate subheadings for right nav in resources
gem 'haml-rails' # makes rails create haml in generators, etc.
gem 'redcarpet' # haml interpreter
#gem 'autosaveable', :path => "/Volumes/Not_Mum/Dropbox/Projects/autosaveable"
gem 'autosaveable', :git => 'https://github.com/ad-dc/autosaveable.git' # autosave feature
gem 'sass_rails_patch' # adds something important to SASS
gem 'magickly', :git => "https://github.com/ad-dc/magickly" # image resizing service
gem 'clockwork', :git => "https://github.com/ad-dc/clockwork" # scheduled tasks on heroku
gem 'resque_mailer' # turns mail().deliver into a resque queue
gem 'awesomemailer' #inlines css for actionmailers
gem 'doc_raptor' #API used for PDF Output
gem 'aasm' # State machine
gem 'acts_as_taggable_on' #handles tags for passages
gem 'select2-rails' #tag fieldtype
gem 'cache_rocket' #Cache partials and replace any dynamic content using helpers
gem 'cache_digests' #Append template info to the cache key so if you change a view template you get new cache keys. Standard in Rails 4.
gem 'kaminari' #pagination for release notes

gem "searchkick", "= 1.1.0" #ElasticSearch integration
gem 'rack-zippy' #serve gzipped assets where possible
group :assets do
  gem 'sass-rails' # adds sass to rails pipeline
  gem 'compass-rails' # adds compass to pipeline
  gem "compass-normalize-plugin" # adds normalize to compass
  gem "susy" # responsive css framework for compass
  gem 'coffee-rails', '~> 3.2.1' # adds coffeescript
  gem 'uglifier', '>= 1.0.3' # compresses/minimizies/uglifies JS/CSS
  gem 'ejs' # encapsulated javascript- javascript template support
  gem 'turbo-sprockets-rails3' # only recompile changed assets instead of everything all the time
  gem 'oily_png' #speeds up png spriting via C extension
end

group :production, :devstaging do
  gem 'newrelic_rpm' # new relic integation
end

group :devstaging, :development, :test do
  gem "letter_opener"
end

group :development, :test do
  gem "rspec-rails", ">= 2.11.4" # testing framework
  gem "faker" # quickly generate placeholder text
  gem "factory_girl_rails", ">= 4.1.0" # factory framework
  gem "pry", "~> 0.9.10" # can't live without it
  gem 'terminal-notifier-guard' #if /darwin/ =~ RUBY_PLATFORM # notification center integration
  gem 'guard' # autorun tasks on change
  gem 'guard-rspec' # rspec integration for guard
  #gem 'guard-livereload' # livereload integration on change
  #gem 'rack-livereload' # livereload serverside in rack
end

group :development do
  gem 'thin' # Use thin as the webserver in dev to suppress those stupid "cannot determine content-length" errors
  gem "quiet_assets", ">= 1.0.1"  # don't tell me about assets being served in the logs
  gem "better_errors", ">= 0.3.2"  # cant live without.
  #gem 'therubyracer' # For multios development
  gem "binding_of_caller"
end

group :test do
  gem 'sqlite3' # test db
  gem "capybara", ">= 2.0.1"
  # gem "database_cleaner", ">= 1.2.0" # clears the database between tests
  gem "database_cleaner", git: 'https://github.com/bmabey/database_cleaner.git'
  gem "launchy", "~> 2.1.2" # lets capybara launch your browser
  gem 'rb-fsevent', '~> 0.9.1' # filesystem change event watcher
  gem 'capybara-mechanize' # fill out forms/click links with capybara
  gem "poltergeist" # headless javascript browser
  gem "shoulda" # adds some extra helpful validation helpers to should
  gem 'resque_spec' #a test double of Resque for rspec and cucumber
end
