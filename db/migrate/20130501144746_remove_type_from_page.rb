class RemoveTypeFromPage < ActiveRecord::Migration
  #cleaning up the tables
  def change
    remove_column :pages, :page_type
    remove_column :features, :severity
  end
end
