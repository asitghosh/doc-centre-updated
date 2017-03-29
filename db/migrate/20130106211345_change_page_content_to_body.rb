class ChangePageContentToBody < ActiveRecord::Migration
  def change
    rename_column :pages, :content, :body
  end
end
