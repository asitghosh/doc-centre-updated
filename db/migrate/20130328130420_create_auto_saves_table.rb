class CreateAutoSavesTable < ActiveRecord::Migration
  def change
    create_table :auto_saves do |t|
      t.string :item_type
      t.integer :item_id
      t.string :event
      t.string :whodunnit
      t.text :object
      t.text :object_changes
      t.timestamps
    end
    add_index "auto_saves", ["item_type", "item_id"], :name => "index_auto_saves_on_item_type_and_item_id"
  end
end
