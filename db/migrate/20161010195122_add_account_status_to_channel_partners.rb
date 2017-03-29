class AddAccountStatusToChannelPartners < ActiveRecord::Migration
  def change
    add_column :channel_partners, :marketplace_account_status, :string
    add_column :channel_partners, :marketplace_edition, :string
  end
end
