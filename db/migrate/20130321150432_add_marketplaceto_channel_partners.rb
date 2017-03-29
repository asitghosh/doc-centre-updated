class AddMarketplacetoChannelPartners < ActiveRecord::Migration
  def change
    add_column :channel_partners, :marketplace_url, :string, :default => "https://www.appdirect.com/home"
  end
end
