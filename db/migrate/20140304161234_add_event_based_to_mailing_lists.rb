class AddEventBasedToMailingLists < ActiveRecord::Migration
  def change
    add_column :mailing_lists, :event_based, :boolean
  end
end
