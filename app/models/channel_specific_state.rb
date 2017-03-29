class ChannelSpecificState < ActiveRecord::Base

  attr_accessible :task, :status, :channel_partner_id
  validates_presence_of :task, :status, :channel_partner_id

  belongs_to :channel_specific_state, polymorphic: true
  belongs_to :channel_partner

  def self.mark(options = {}, status="processing")
    m = where(options).first_or_create
    m.update_attribute(:status, status)
    m.touch
  end

end
