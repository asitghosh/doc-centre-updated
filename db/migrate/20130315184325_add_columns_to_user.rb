class AddColumnsToUser < ActiveRecord::Migration
  def change
    add_column :users, :welcome_flag, :boolean
    add_column :users, :phone, :string
  end
end
