class CreateFeaturesTable < ActiveRecord::Migration
  def change
    #action, subject_class, subject_id
    create_table :features do |t|
      t.string :title
      t.text :summary
      t.string :severity
      t.integer :release_id
      t.timestamps
    end
  end
end
