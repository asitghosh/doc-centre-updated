class RemovePaperClipFieldsFromChannelParter < ActiveRecord::Migration
  def change
    remove_column :channel_partners, :logo_file_name
    remove_column :channel_partners, :logo_content_type
    remove_column :channel_partners, :logo_file_size
    remove_column :channel_partners, :logo_updated_at
  end
end
