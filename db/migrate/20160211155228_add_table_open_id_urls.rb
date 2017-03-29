class AddTableOpenIdUrls < ActiveRecord::Migration
  def change
  	create_table :open_id_urls do |t|
      t.string :open_id_url
      t.integer :channel_partner_id
    end
  end
end
