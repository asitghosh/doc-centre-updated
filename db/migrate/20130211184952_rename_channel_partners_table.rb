class RenameChannelPartnersTable < ActiveRecord::Migration
  def up
    rename_table :channelpartners, :channel_partners
  end

  def down
    rename_table :channel_partners, :channelpartners
  end
end
