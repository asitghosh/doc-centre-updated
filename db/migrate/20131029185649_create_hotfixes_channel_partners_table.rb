class CreateHotfixesChannelPartnersTable < ActiveRecord::Migration
  def self.up
    create_table :channel_partners_hotfixes do |t|
		t.integer	:hotfix_id
		t.integer   :channel_partner_id
    end
  end

  def self.down
    drop_table :channel_partners_hotfixes
  end
end
