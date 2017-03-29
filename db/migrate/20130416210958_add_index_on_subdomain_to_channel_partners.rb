class AddIndexOnSubdomainToChannelPartners < ActiveRecord::Migration
  def change
    add_index(:channel_partners, :subdomain)
  end
end
