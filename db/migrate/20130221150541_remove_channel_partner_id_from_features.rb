class RemoveChannelPartnerIdFromFeatures < ActiveRecord::Migration
  def change
    remove_column :features, :channel_partner_id
  end
end
