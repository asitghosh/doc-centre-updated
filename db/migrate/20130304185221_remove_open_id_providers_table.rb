class RemoveOpenIdProvidersTable < ActiveRecord::Migration
  def change
    drop_table :open_id_providers
  end
end
