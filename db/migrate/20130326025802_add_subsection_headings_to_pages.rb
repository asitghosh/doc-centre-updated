class AddSubsectionHeadingsToPages < ActiveRecord::Migration
  def change
    add_column :pages, :subsection_headings, :text
  end
end
