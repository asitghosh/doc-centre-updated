class AddImpersonationIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :impersonation_id, :integer
  end
end
