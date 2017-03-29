class AddAnnotations < ActiveRecord::Migration
  def change
  	create_table :annotations do |t|
      t.integer :user_id
      t.integer :page_id
      t.string :page_permalink
      t.string :quote
      t.text :text
      t.text :ranges
      t.text :permissions
      t.string :aasm_state

      t.timestamps
    end
  end
end
