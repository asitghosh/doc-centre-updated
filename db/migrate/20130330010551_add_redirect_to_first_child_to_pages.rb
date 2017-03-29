class AddRedirectToFirstChildToPages < ActiveRecord::Migration
  def change
    add_column :pages, :redirect_to_first_child, :boolean, :default => false
  end
end
