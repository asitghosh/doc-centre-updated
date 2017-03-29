class AddGeneralnotesToReleases < ActiveRecord::Migration
  def change
    add_column :releases, :general_notes, :text
  end
end
