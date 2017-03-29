class ChannelSpecificContents < ActiveRecord::Migration
  def change
    #action, subject_class, subject_id
    create_table :channel_specific_contents do |t|
      t.string :channel_specific_type
      t.integer :channel_specific_id
      t.text :content
      t.timestamps
    end
  end
end
