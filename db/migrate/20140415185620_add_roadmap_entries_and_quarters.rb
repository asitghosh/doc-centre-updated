class AddRoadmapEntriesAndQuarters < ActiveRecord::Migration
  def change
    create_table :roadmaps do |t|
      t.string    :title
      t.string    :product
      t.string	  :pub_status
      t.integer	 :release_id
      t.text		  :content
      t.string    :slug
      t.string    :permalink
      t.boolean   :redirect_to_first_child
      t.text      :subsection_headings
      t.integer   :sortable_order
      t.string    :ancestry
      t.integer   :ancestry_depth,          :default => 0
      t.boolean   :is_a_quarter,            :default => false

      t.timestamps
    end
  end
end
