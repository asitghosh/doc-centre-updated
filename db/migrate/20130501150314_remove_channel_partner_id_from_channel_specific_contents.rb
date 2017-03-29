class RemoveChannelPartnerIdFromChannelSpecificContents < ActiveRecord::Migration
  def change
    remove_column :channel_specific_contents, :channel_partner_id
  end
end
