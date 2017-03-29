class AddTimeToSendLatestReleaseToChannelPartners < ActiveRecord::Migration
  def change
    add_column :channel_partners, :time_to_send_latest_release, :string
  end
end
