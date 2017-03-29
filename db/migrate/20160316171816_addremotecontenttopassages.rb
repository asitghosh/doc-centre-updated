class Addremotecontenttopassages < ActiveRecord::Migration
  def change
  	add_column :passages, :remote_content, :string
  end
end
