class CreateReleasesTable < ActiveRecord::Migration
  def change
    #action, subject_class, subject_id
    create_table :releases do |t|
      t.integer :number
      t.date :release_date
      t.text :summary
      t.timestamps
    end
  end
end
