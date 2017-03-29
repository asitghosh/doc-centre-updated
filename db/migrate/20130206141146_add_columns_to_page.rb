class AddColumnsToPage < ActiveRecord::Migration
  def change
    add_column :pages, :page_pub_status, :string
    add_column :pages, :page_pub_date, :datetime
    add_column :pages, :page_type, :string
  end
end
