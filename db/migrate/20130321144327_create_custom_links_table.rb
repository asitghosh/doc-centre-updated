class CreateCustomLinksTable < ActiveRecord::Migration
  def change
    #action, subject_class, subject_id
    create_table :custom_links do |t|
      t.string :label
      t.string :url
      t.string :link_type
      t.integer :channel_partner_id
      t.timestamps
    end
  end
end
