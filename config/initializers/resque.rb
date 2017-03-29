require 'resque/server'
require 'resque/failure/multiple'
require 'resque/failure/airbrake'
require 'resque/failure/redis'
Resque.redis = REDIS_WORKER

Resque::Failure::Airbrake.configure do |config|
  config.api_key = ENV['ERRBIT_KEY']
  config.secure = false # only set this to true if you are on a paid Airbrake plan
end

Resque::Failure::MultipleWithRetrySuppression.classes = [Resque::Failure::Redis, Resque::Failure::Airbrake]
Resque::Failure.backend = Resque::Failure::MultipleWithRetrySuppression