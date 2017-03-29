class AddColorToChannelPartners < ActiveRecord::Migration
  def change
    add_column :channel_partners, :color, :string
  end
end
