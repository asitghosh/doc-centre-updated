class AddApiKeyToChannelPartners < ActiveRecord::Migration
  def change
    add_column :channel_partners, :api_key, :string
  end
end
