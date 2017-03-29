class AddIconToPages < ActiveRecord::Migration
  def change
    add_column :pages, :logo, :string
  end
end
