class AddFrameMakerIntegrationToPages < ActiveRecord::Migration
  def change
  	add_column :pages, :is_framemaker, :boolean, :default => false
  	add_column :pages, :framemaker_page_id, :string
  	add_column :pages, :framemaker_export_location, :string
  	add_column :pages, :framemaker_book, :string
  	add_column :pages, :framemaker_chapter, :string
  end
end
