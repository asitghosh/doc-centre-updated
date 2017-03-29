class AddchannelIdtousers < ActiveRecord::Migration
  def change
    add_column :users, :channe_id, :integer
  end
end
