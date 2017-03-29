class RemovePdfFlagFromChannelPartners < ActiveRecord::Migration
  def change
    remove_column :channel_partners, :pdf_flag
  end
end
