class CreateChannelPartnersChannelSpecificStates < ActiveRecord::Migration
  def change
    create_table :channel_partners_channel_specific_states do |t|
      t.integer "channel_partner_id"
      t.integer "channel_specific_state_id"
    end
  end
end
