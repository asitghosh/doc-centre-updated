class AddSummaryToChannelSpecificContent < ActiveRecord::Migration
  def change
    add_column :channel_specific_contents, :summary, :text
  end
end
