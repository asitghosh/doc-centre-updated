class RemovePdfUrlFromPages < ActiveRecord::Migration
  def change
    remove_column :pages, :pdf_url
  end
end
