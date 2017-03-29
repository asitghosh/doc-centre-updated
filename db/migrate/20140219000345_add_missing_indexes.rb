class AddMissingIndexes < ActiveRecord::Migration
  class AddMissingIndexes < ActiveRecord::Migration
    def change
      add_index :channel_specific_contents, [:channel_specific_id, :channel_specific_type]
      add_index :channel_partners_channel_specific_contents, [:channel_partner_id, :channel_specific_content_id]
      add_index :users_mailing_lists, [:user_id, :mailing_list_id]
      add_index :users_mailing_lists, [:mailing_list_id, :user_id]
      add_index :permissions, :role_id
      add_index :channel_partners_users, [:channel_partner_id, :account_rep_id]
      add_index :channel_partners_users, [:account_rep_id, :user_id]
      add_index :features, :release_id
      add_index :channel_partners_features, [:channel_partner_id, :feature_id]
      add_index :channel_partners_features, [:feature_id, :channel_partner_id]
      add_index :hotfixes, :release_id
      add_index :channel_partners_hotfixes, [:channel_partner_id, :hotfix_id]
      add_index :channel_partners_hotfixes, [:hotfix_id, :channel_partner_id]
      add_index :custom_links, :channel_partner_id
      add_index :channel_specific_states, [:channel_specific_state_id, :channel_specific_state_type]
      add_index :channel_specific_states, :channel_partner_id
    end
  end
end
