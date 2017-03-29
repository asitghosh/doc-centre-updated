class AddShowUpdateToUsers < ActiveRecord::Migration
  def change
    add_column :users, :show_update, :boolean
  end
end