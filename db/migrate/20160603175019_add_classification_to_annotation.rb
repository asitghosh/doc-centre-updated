class AddClassificationToAnnotation < ActiveRecord::Migration
  def change
    add_column :annotations, :classification, :string
  end
end
