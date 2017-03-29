class AddAbleToSeeIsvInfoToChannelPartners < ActiveRecord::Migration
  def change
    add_column :channel_partners, :able_to_see_isv, :boolean, :default => :false
  end
end
