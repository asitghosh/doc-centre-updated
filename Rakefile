#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'resque/tasks'
require 'resque_scheduler/tasks'
DocCenter::Application.load_tasks

task "resque:setup" => :environment do
  ENV['QUEUE'] = '*' if ENV['QUEUE'].blank?

  Resque.before_fork = Proc.new { ActiveRecord::Base.establish_connection }
end

desc "Alias for resque:work"
task "jobs:work" => "resque:work"

namespace "maintenance" do
  task :on do
    puts "maintenance mode --enabled"
    AppSettings.find_by_key("superadmin_only_mode").update_column("value", "true")
  end

  task :off do
    puts "maintenance mode --disabled"
    AppSettings.find_by_key("superadmin_only_mode").update_column("value", "false")
  end

end

namespace "search" do
  task :reindex do
    Release.reindex
    Page.reindex
    Faq.reindex
    Roadmap.reindex
  end
end

namespace "production" do
  task :backup do
    make_backup(env = 'doc-center')
  end

  # task :push_db_staging do
  #   make_backup('doc-center')
  #   binding.pry
  #   # puts "Push Production DB to Staging: are you sure? (anything but 'yes' will cancel)"
  #   # r = $stdin.gets.chomp
  #   # heroku("pgbackups:restore DATABASE #{heroku("pgbackups:url --app doc-center")} --app doc-center-dev --confirm doc-center-dev") if r == 'yes'
  # end
end

namespace "staging" do
  task :backup do
    make_backup('doc-center-dev')
  end

  # task :push_db_production do
  #   url = make_backup('doc-center-dev')
  #   puts "---THIS IS PROBABLY A BAD IDEA--- \n Push Staging DB to Production: are you sure? (anything but 'yes' will cancel)\n---THIS IS PROBABLY A BAD IDEA---"
  #   r = $stdin.gets.chomp

  # end
end

#heroku commands crap themselves inside rake, use this method instead

def heroku(command)
  s = system("GEM_HOME='' BUNDLE_GEMFILE='' GEM_PATH='' RUBYOPT='' /usr/local/heroku/bin/heroku #{command}")
end

def make_backup(env = 'doc-center-dev')
  heroku("pgbackups:capture --expire --app #{env}")
end
