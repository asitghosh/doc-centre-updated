class AddSlugToFaq < ActiveRecord::Migration
  def change
    add_column :faqs, :slug, :string
  end
end
