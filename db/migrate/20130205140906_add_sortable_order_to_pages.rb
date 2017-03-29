class AddSortableOrderToPages < ActiveRecord::Migration
  def change
    add_column :pages, :sortable_order, :integer
  end
end
