class AddSubjectToMailingLists < ActiveRecord::Migration
  def change
    add_column :mailing_lists, :subject, :string
    add_column :mailing_lists, :description, :string
  end
end
