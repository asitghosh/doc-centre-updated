class AddContentToFeatures < ActiveRecord::Migration
  def change
    add_column :features, :content, :text
  end
end
