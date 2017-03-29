# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
#require 'email_spec'
#require 'rspec/autorun'
require 'capybara/rspec'
require 'capybara/rails'
require 'capybara/mechanize'
require 'capybara/poltergeist'

module Capybara::Poltergeist
  class Client
    private
   def redirect_stdout
      prev = STDOUT.dup
      prev.autoclose = false
      $stdout = @write_io
      STDOUT.reopen(@write_io)

      prev = STDERR.dup
      prev.autoclose = false
      $stderr = @write_io
      STDERR.reopen(@write_io)
      yield
    ensure
      STDOUT.reopen(prev)
      $stdout = STDOUT
      STDERR.reopen(prev)
      $stderr = STDERR
    end
  end
end

class WarningSuppressor
  class << self
    def write(message)
      if message =~ /QFont::setPixelSize: Pixel size <= 0/ || message =~/CoreText performance note:/ then 0 else puts(message);1;end
    end
  end
end

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

Capybara.register_driver :poltergeist do |app|
  options = {
    :timeout => 120,
    :phantomjs_logger => WarningSuppressor
  }
  Capybara::Poltergeist::Driver.new(app, options)
end

Capybara.configure do |config|
  Capybara.javascript_driver = :poltergeist
  Capybara.always_include_port = true
  Capybara.ignore_hidden_elements = false
end


RSpec.configure do |config|

  config.treat_symbols_as_metadata_keys_with_true_values = true
  original_stderr = $stderr
  original_stdout = $stdout

  config.include FactoryGirl::Syntax::Methods
  # config.include(EmailSpec::Helpers)
  # config.include(EmailSpec::Matchers)
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  #omniauth mocking
  OmniAuth.config.test_mode = true

  oa_admin = OmniAuth::AuthHash.new({
    'uid' => '12345',
    'info' => {
      'name' => 'Test User',
      'email' => 'testuser@appdirect.com',
      'first_name' => 'Test',
      'last_name' => 'User'
    },
    'credentials' => {
      'token' => 'tokentoken',
      'secret' => 'thisissosecret'
    },
    'extra' => {
      "roles" => ['USER', 'SYS_ADMIN']
    }
  })

  OmniAuth.config.mock_auth[:default] = oa_admin
  OmniAuth.config.logger = Rails.logger
  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.around(:each, :caching) do |example|
    caching = ActionController::Base.perform_caching
    ActionController::Base.perform_caching = example.metadata[:caching]
    example.run
    ActionController::Base.perform_caching = caching
  end

  config.before(:suite) do
    # Redirect stderr and stdout
    $stderr = File.open(File::NULL, "w")
    $stdout = File.open(File::NULL, "w")

    AppSettings.create({ :key => "superadmin_only_mode", :value => "false" })
    MailingList.create({ title: "Weekly Digest", joinable: true, internal_only: false })

    Release.searchkick_index.delete if Release.searchkick_index.exists?
    Manual.searchkick_index.delete if Manual.searchkick_index.exists?
    Support.searchkick_index.delete if Support.searchkick_index.exists?
    Faq.searchkick_index.delete if Faq.searchkick_index.exists?
    Roadmap.searchkick_index.delete if Roadmap.searchkick_index.exists?

    create_channel_partners
    DatabaseCleaner.strategy = :truncation, { :except => %w[app_settings mailing_lists channel_partners open_id_urls] }
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.after(:suite) do
    AppSettings.delete_all
    MailingList.delete_all
    ChannelPartner.delete_all
    OpenIDUrl.delete_all

    #reconnect stdio
    $stderr = original_stderr
    $stdout = original_stdout
  end

  #Devise
  # config.include Devise::TestHelpers, :type => :controller
  # config.extend ControllerMacros, :type => :controller

  #The Following is from: https://github.com/resque/resque/wiki/RSpec-and-Resque
  #It creates a Redis instance specifically for testing.
  # REDIS_PID = "#{Rails.root}/tmp/pids/redis-test.pid"
  # REDIS_CACHE_PATH = "#{Rails.root}/tmp/cache/"

  # config.before(:suite) do
  #   redis_options = {
  #     "daemonize"     => 'yes',
  #     "pidfile"       => REDIS_PID,
  #     "port"          => 9736,
  #     "timeout"       => 300,
  #     "save 900"      => 1,
  #     "save 300"      => 1,
  #     "save 60"       => 10000,
  #     "dbfilename"    => "dump.rdb",
  #     "dir"           => REDIS_CACHE_PATH,
  #     "loglevel"      => "debug",
  #     "logfile"       => "stdout",
  #     "databases"     => 16
  #   }.map { |k, v| "#{k} #{v}" }.join("\n")
  #   `echo '#{redis_options}' | redis-server -`
  # end

  # config.after(:suite) do
  #   %x{
  #     cat #{REDIS_PID} | xargs kill -QUIT
  #     rm -f #{REDIS_CACHE_PATH}dump.rdb
  #   }
  # end
end
