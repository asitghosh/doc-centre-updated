class AddRichPickerToPages < ActiveRecord::Migration
  def change
    add_column :pages, :file_upload, :string
  end
end
