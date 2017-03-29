class CreateChannelPartnersChannelSpecificContentsTable < ActiveRecord::Migration
  def change
    create_table :channel_partners_channel_specific_contents do |t|
      t.integer :channel_partner_id
      t.integer :channel_specific_content_id
    end
  end
end
