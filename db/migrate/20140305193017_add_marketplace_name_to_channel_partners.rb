class AddMarketplaceNameToChannelPartners < ActiveRecord::Migration
  def change
    add_column :channel_partners, :marketplace_name, :string
  end
end
