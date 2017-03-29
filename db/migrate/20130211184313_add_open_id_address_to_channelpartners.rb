class AddOpenIdAddressToChannelpartners < ActiveRecord::Migration
  def change
    add_column :channelpartners, :open_id_address, :string
  end
end
