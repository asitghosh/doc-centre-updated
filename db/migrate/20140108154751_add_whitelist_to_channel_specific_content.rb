class AddWhitelistToChannelSpecificContent < ActiveRecord::Migration
  def change
    add_column :channel_specific_contents, :whitelist, :boolean
  end
end
