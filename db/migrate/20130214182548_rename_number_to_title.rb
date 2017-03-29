class RenameNumberToTitle < ActiveRecord::Migration
  def change
    rename_column :releases, :number, :title
    add_column :features, :channel_partner_id, :integer
  end
end
