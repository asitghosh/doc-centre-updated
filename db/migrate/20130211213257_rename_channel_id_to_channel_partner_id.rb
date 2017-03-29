class RenameChannelIdToChannelPartnerId < ActiveRecord::Migration
  def change
    rename_column :users, :channel_id, :channel_partner_id
  end
end
