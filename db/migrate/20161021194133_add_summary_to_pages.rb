class AddSummaryToPages < ActiveRecord::Migration
  def change
    add_column :pages, :summary, :string
  end
end
