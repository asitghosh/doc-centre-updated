class AddAttachmentLogoToChannelPartners < ActiveRecord::Migration
  def self.up
    change_table :channel_partners do |t|
      t.attachment :logo
    end
  end

  def self.down
    drop_attached_file :channel_partners, :logo
  end
end
