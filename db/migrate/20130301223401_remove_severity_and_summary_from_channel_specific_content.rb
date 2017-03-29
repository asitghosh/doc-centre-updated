class RemoveSeverityAndSummaryFromChannelSpecificContent < ActiveRecord::Migration
  def change
    remove_column :channel_specific_contents, :severity
    remove_column :channel_specific_contents, :summary
  end
end
