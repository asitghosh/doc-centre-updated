class CreateChannelpartners < ActiveRecord::Migration
  def change
    create_table :channelpartners do |t|
      t.string :name

      t.timestamps
    end
  end
end
