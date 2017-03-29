# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# Environment variables (ENV['...']) are set in the file config/application.yml.
# See http://railsapps.github.com/rails-environment-variables.html
#
puts 'ROLES'
YAML.load(ENV['ROLES']).each do |role|
  Role.find_or_create_by_name({ :name => role }, :without_protection => true)
  puts '`--- role: ' << role
end

puts "PERMISSIONS (for superadmin)"
sa = Role.where(:name => "superadmin").first
Permission.create({ action: :manage, subject_class: :all, role_id: sa.id })
puts "`--- Role #{sa.id}'s (superadmins) are super"

puts 'AppDirect ChannelPartner'
ChannelPartner.find_or_create_by_name({ name: "AppDirect", open_id_address: "http://appdirect.com/openid/id", subdomain: "ad", marketplace_url: "https://www.appdirect.com/home", logo: "https://s3.amazonaws.com/doc-center-dev/rich/rich_files/rich_files/16/original/appdirect-logo-light-20copy.png", color: "006080" })
ChannelPartner.find_or_create_by_name({ name: "AppDirect Test", open_id_address: "http://test.appdirect.com/openid/id", subdomain: "test", marketplace_url: "https://test.appdirect.com/home", logo: "https://s3.amazonaws.com/doc-center-dev/rich/rich_files/rich_files/17/original/appdirect-logo-light-test.png" })

puts 'Initializing Default Pages'
Page.find_or_create_by_title({ title: "Manuals", body: "default guide page", slug: "manuals", permalink: "guides" })

puts 'Initializing Email Lists'
MailingList.find_or_create_by_title({ title: "Daily Digest", joinable: true, internal_only: false, subject: "Daily Digest", event_based: false })
MailingList.find_or_create_by_title({ title: "Weekly Digest", joinable: true, internal_only: false, subject: "Weekly Digest", event_based: false })
MailingList.find_or_create_by_title({ title: "Release Notification", joinable: true, internal_only: false, subject: "Release Notification", event_based: true })
MailingList.find_or_create_by_title({ title: "Hotfix Notification", joinable: true, internal_only: false, subject: "Hotfix Notification", event_based: true })
MailingList.find_or_create_by_title({ title: "Channel Partner Mailing List", joinable: false, internal_only: false, subject: "Channel Partner Mailing List", event_based: true })
#MailingList.find_or_create_by_title({ title: "Updates", joinable: true, internal_only: true })

puts 'Initializing Mutable Application Settings'
AppSettings.find_or_create_by_key({ key: "superadmin_only_mode", :value => false })

# DH - I don't think we need this as we're not ever accepting email/pw for loginskees
#
# puts 'DEFAULT USERS'
# user = User.find_or_create_by_email :name => ENV['ADMIN_NAME'].dup, :email => ENV['ADMIN_EMAIL'].dup, :password => ENV['ADMIN_PASSWORD'].dup, :password_confirmation => ENV['ADMIN_PASSWORD'].dup
# puts 'user: ' << user.name
# user.add_role :admin
