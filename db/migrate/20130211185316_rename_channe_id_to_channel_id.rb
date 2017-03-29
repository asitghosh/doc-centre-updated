class RenameChanneIdToChannelId < ActiveRecord::Migration
  def change
    rename_column :users, :channe_id, :channel_id
  end
end
