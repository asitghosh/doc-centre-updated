class CreateOpenIdProviders < ActiveRecord::Migration
  def change
    create_table :open_id_providers do |t|
      t.string :subdomain
      t.string :open_id_url

      t.timestamps
    end
  end
end
