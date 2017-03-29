class AddChannelPartnerIdToChannelSpecificStates < ActiveRecord::Migration
  def change
    add_column :channel_specific_states, :channel_partner_id, :integer
  end
end
