class AddPdfUrlToPages < ActiveRecord::Migration
  def change
    add_column :pages, :pdf_url, :string
  end
end
