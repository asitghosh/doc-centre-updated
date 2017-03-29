class AddTagDescription < ActiveRecord::Migration
  def change
  	create_table :tag_descriptions do |t|
      t.string :description
      t.integer :tag_id
      t.timestamps 
    end
  end
end


# @tag_d = TagDescription.where("tag_id = ?", @tag.id)