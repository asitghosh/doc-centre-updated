class AddAppSettingsTable < ActiveRecord::Migration
  def self.up
    create_table :app_settings do |t|
    	t.string    :value
    	t.string    :key
    end
  end

  def self.down
    drop_table :app_settings
  end
end
