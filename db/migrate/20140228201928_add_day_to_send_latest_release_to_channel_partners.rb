class AddDayToSendLatestReleaseToChannelPartners < ActiveRecord::Migration
  def change
    add_column :channel_partners, :day_to_send_latest_release, :string
  end
end
