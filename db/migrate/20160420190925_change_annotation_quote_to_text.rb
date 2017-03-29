class ChangeAnnotationQuoteToText < ActiveRecord::Migration
  def up
    change_column :annotations, :quote, :text
  end

  def down
    change_column :annotations, :quote, :string
  end
end
