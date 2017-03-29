class CreateUpdates < ActiveRecord::Migration
  def change
    create_table :updates do |t|
      t.string :title
      t.text :content
      t.date :release_date
      t.string :pub_status
      t.timestamps
    end
  end
end
