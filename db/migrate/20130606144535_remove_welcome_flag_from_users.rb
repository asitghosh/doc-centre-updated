class RemoveWelcomeFlagFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :welcome_flag
  end
end
