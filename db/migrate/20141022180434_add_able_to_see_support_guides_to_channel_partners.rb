class AddAbleToSeeSupportGuidesToChannelPartners < ActiveRecord::Migration
  def change
    add_column :channel_partners, :able_to_see_supports, :boolean, :default => false
  end
end
