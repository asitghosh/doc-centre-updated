require File.expand_path(File.join(File.dirname(__FILE__), 'config', 'boot'))
require File.expand_path(File.join(File.dirname(__FILE__), 'config', 'environment'))

require 'clockwork'
include Clockwork

module Clockwork
  configure do |config|
    config[:sleep_timeout] = 5
    config[:tz] = 'America/Los_Angeles'
  end
end

every(1.day, 'daily.digest', :at => '21:00') { MailingList.find_by_title("Daily Digest").send_email if Rails.env.production? }

every(1.day, 'annotation.digest', :at => '20:00') { Annotation.send_digest if Rails.env.production? }

every(1.week, 'weekly.digest', :at => 'Fri 21:00') { MailingList.find_by_title("Weekly Digest").send_email if Rails.env.production? }

#every(3.minutes, "week.test"){ puts "hello world" }

every(1.day, 'nightly_tasks.maintenance', :at => '23:00') { Resque.enqueue(NightlyTasks) }

every(1.hour, 'daily.cp_update', :at => '**:00'){ ChannelPartner.where(:day_to_send_latest_release => Time.zone.now().strftime("%A"),
                                                                       :time_to_send_latest_release => Time.zone.now().strftime("%k").gsub(/\s/, "")
                                                                       ).each { |cp| cp.send_latest_release }}
