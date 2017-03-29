class AddQuickstartToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :quickstart, :boolean, :default => true
  end
end
