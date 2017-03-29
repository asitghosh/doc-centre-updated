class AddMergedDateToFeatures < ActiveRecord::Migration
  def change
    add_column :features, :merge_date, :datetime
  end
end
