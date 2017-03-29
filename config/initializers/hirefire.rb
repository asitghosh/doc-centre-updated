if defined?(HireFire::Resource) 
  HireFire::Resource.configure do |config|
    config.dyno(:worker) do
      HireFire::Macro::Resque.queue
    end
  end
end