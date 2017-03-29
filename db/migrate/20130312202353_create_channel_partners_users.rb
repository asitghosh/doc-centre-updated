class CreateChannelPartnersUsers < ActiveRecord::Migration
  def change
    create_table :channel_partners_users do |t|
      t.integer :account_rep_id
      t.integer :channel_partner_id
    end
  end
end
