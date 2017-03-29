class ChangeReleasesTitleFromIntegerToString < ActiveRecord::Migration
  def change
    change_column :releases, :title, :string
  end
end
