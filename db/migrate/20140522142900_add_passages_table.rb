class AddPassagesTable < ActiveRecord::Migration
  def self.up
    create_table :passages do |t|
      t.text       :content
      t.integer    :sortable_order
      t.string     :passages_type
      t.integer    :passages_id
      t.string     :type_name
      t.timestamps
    end
  end

  def self.down
    drop_table :passages
  end
end
