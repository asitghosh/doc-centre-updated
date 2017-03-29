class ChannelSpecificContent < ActiveRecord::Base

  attr_accessible :content,
                  :channel_partner_ids,
                  :whitelist, #boolean 0 = blacklist 1 = whitelist
                  :passages_attributes
  belongs_to :channel_specific, polymorphic: true
  has_and_belongs_to_many :channel_partners
  has_many :passages, as: :passages
  
  accepts_nested_attributes_for :passages, :allow_destroy => true

  validates_presence_of :content, :channel_partner_ids

  def self.of(channel_partner_id)
      joins('LEFT OUTER JOIN "channel_partners_channel_specific_contents" ON "channel_partners_channel_specific_contents"."channel_specific_content_id" = "channel_specific_contents"."id" LEFT OUTER JOIN "channel_partners" ON "channel_partners"."id" = "channel_partners_channel_specific_contents"."channel_partner_id"')
      .where('((channel_specific_contents.whitelist = ? OR channel_specific_contents.whitelist IS NULL) AND channel_partners.id IN (?)) OR (channel_specific_contents.whitelist = ? AND channel_partners.id NOT IN(?))', true, channel_partner_id, false, channel_partner_id)
  end



  # ChannelSpecificContent.joins(:channel_partners).where('channel_partners.id IN (?)', 2)

  # If you want to grab content without using the default scope as a mandatory filter:
  # ChannelSpecificContent.unscoped.where(id: 1123)

end
