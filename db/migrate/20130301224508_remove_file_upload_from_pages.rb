class RemoveFileUploadFromPages < ActiveRecord::Migration
  def change
    remove_column :pages, :file_upload
  end
end
