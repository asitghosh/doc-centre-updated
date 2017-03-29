class AddpubstatusToReleases < ActiveRecord::Migration
  def change
    add_column :releases, :pub_status, :string
    add_column :features, :pub_status, :string
  end
end
