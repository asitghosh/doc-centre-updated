class AddChannelPartnerIdToChannelSpecificContents < ActiveRecord::Migration
  def change
    add_column :channel_specific_contents, :channel_partner_id, :integer
  end
end
