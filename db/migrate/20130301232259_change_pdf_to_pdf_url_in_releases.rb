class ChangePdfToPdfUrlInReleases < ActiveRecord::Migration
  def change
    add_column :releases, :pdf_url, :string
  end
end
