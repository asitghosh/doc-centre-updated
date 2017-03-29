class AddDefaultValueToUserWelcomeFlag < ActiveRecord::Migration
  def change
    change_column :users, :welcome_flag, :boolean, :default => true
  end
end
