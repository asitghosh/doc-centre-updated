class CreateFeaturesChannelPartnersJoinTable < ActiveRecord::Migration
  def change
    create_table :channel_partners_features, :id => false do |t|
      t.integer :feature_id
      t.integer :channel_partner_id
    end
  end
end
