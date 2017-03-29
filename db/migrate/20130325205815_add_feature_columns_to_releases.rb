class AddFeatureColumnsToReleases < ActiveRecord::Migration
  def change
    add_column :releases, :marketplace_improvements, :text
    add_column :releases, :manager_improvements, :text
    add_column :releases, :devcenter_improvements, :text
    add_column :releases, :api_improvements, :text
  end
end
