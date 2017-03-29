class AddLogoToChannelPartners < ActiveRecord::Migration
  def change
    add_column :channel_partners, :logo, :string
  end
end
