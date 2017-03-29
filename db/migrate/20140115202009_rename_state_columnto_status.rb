class RenameStateColumntoStatus < ActiveRecord::Migration
  def change
    rename_column :channel_specific_states, :state, :status
  end
end
