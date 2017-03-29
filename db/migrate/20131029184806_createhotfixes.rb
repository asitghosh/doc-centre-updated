class Createhotfixes < ActiveRecord::Migration
  def self.up
    create_table :hotfixes do |t|
    	t.string    :number
		t.integer	:release_id
		t.text		:content
		t.string	:pub_status
       t.timestamps
    end
  end

  def self.down
    drop_table :hotfixes
  end

end
