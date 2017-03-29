class AddSubsectionHeadingsToReleases < ActiveRecord::Migration
  def change
    add_column :releases, :subsection_headings, :text
  end
end
