class AddRoleIdToPermissions < ActiveRecord::Migration
  def change
    add_column :permissions, :role_id, :integer
  end
end
