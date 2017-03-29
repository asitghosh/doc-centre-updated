class AddPermissionsToChannelPartners < ActiveRecord::Migration
  def change
    add_column :channel_partners, :able_to_see_releases, :boolean, :default => false
    add_column :channel_partners, :able_to_see_user_guides, :boolean, :default => false
    add_column :channel_partners, :able_to_see_roadmaps, :boolean, :default => false
    add_column :channel_partners, :able_to_see_faqs, :boolean, :default => false
  end
end
