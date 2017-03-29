class AddCorporatePortalToReleases < ActiveRecord::Migration
  def change
    add_column :releases, :corporate_portal, :text
  end
end
