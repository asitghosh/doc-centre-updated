class PermissionsTable < ActiveRecord::Migration
  def change
    #action, subject_class, subject_id
    create_table :permissions do |t|
      t.string :action
      t.string :subject_class
      t.integer :subject_id
    end
  end
end
