class RemovePdfUrlFromReleases < ActiveRecord::Migration
  def change
    remove_column :releases, :pdf_url
  end
end
