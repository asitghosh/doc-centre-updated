class MailingList < ActiveRecord::Base
  has_and_belongs_to_many :users, :join_table => :users_mailing_lists
  attr_accessible :title,
                  :joinable,
                  :internal_only,
                  :subject,
                  :description,
                  :event_based

  scope :user_joinable, where('joinable = ?', true)
  scope :digests, user_joinable.where('event_based IS NULL')
  scope :notifications, user_joinable.where('event_based = ?', true)
  # instance methods

  def user_joinable?
  	self.joinable == true
  end

  def send_email(email = nil)
  	self.users.pluck(:channel_partner_id).uniq.each do |channel_partner_id|
  		EmailDigest.send_mail(channel_partner_id, self.id, { :to => email }).deliver
  	end
  end

  def send_notification(resource_class, resource_id, channel_partner_id, options = {})
    EventNotification.send_mail(resource_class, resource_id, channel_partner_id, self.id, options).deliver if self.users.pluck(:channel_partner_id).uniq.include?(channel_partner_id)
  end

  def users_for_email(channel_partner_id)
    self.users.where("users.channel_partner_id" => channel_partner_id).with_any_role(:superadmin, :editor, :account_rep, :appdirect_employee, :channel_admin).collect { |u| u.email }
  end

  def event_based?
    event_based
  end

end
