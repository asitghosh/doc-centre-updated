class RenamePagePubStatusToPubStatus < ActiveRecord::Migration
  def change
    rename_column :pages, :page_pub_status, :pub_status
  end
end
