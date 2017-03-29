class CreateMailingLists < ActiveRecord::Migration
  def self.up
    create_table :mailing_lists do |t|
      t.string    :title
      t.boolean   :joinable
      t.boolean   :internal_only
      t.timestamps
    end

    create_table :users_mailing_lists do |t|
      t.integer   :user_id
      t.integer   :mailing_list_id
    end
  end

  def self.down
    drop_table :mailing_lists
    drop_table :users_mailing_lists
  end
end
