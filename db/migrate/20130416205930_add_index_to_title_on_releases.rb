class AddIndexToTitleOnReleases < ActiveRecord::Migration
  def change
    add_index(:releases, :title)
  end
end
