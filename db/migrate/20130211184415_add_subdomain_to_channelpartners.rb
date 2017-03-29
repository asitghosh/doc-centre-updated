class AddSubdomainToChannelpartners < ActiveRecord::Migration
  def change
    add_column :channelpartners, :subdomain, :string
  end
end
