class CreateChannelSpecificStatesTable < ActiveRecord::Migration
  def change
    create_table :channel_specific_states do |t|
      t.string :channel_specific_state_type
      t.integer :channel_specific_state_id
      t.string :task
      t.string :state
      t.timestamps 
    end
  end
end
