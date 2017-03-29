class AddSeverityToChannelSpecificContent < ActiveRecord::Migration
  def change
    add_column :channel_specific_contents, :severity, :string
  end
end
