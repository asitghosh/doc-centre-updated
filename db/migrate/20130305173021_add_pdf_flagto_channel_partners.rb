class AddPdfFlagtoChannelPartners < ActiveRecord::Migration
  def up
    add_column :channel_partners, :pdf_flag, :boolean
  end
end
