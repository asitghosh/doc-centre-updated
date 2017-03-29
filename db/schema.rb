# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20161021194133) do

  create_table "active_admin_comments", :force => true do |t|
    t.string   "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "annotations", :force => true do |t|
    t.integer  "user_id"
    t.integer  "page_id"
    t.string   "page_permalink"
    t.text     "quote"
    t.text     "text"
    t.text     "ranges"
    t.text     "permissions"
    t.string   "aasm_state"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "classification"
  end

  create_table "app_settings", :force => true do |t|
    t.string "value"
    t.string "key"
  end

  create_table "auto_saves", :force => true do |t|
    t.string   "item_type"
    t.integer  "item_id"
    t.string   "event"
    t.string   "whodunnit"
    t.text     "object"
    t.text     "object_changes"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "auto_saves", ["item_type", "item_id"], :name => "index_auto_saves_on_item_type_and_item_id"

  create_table "channel_partners", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",                                                                :null => false
    t.datetime "updated_at",                                                                :null => false
    t.string   "open_id_address"
    t.string   "subdomain"
    t.string   "logo"
    t.string   "marketplace_url",             :default => "https://www.appdirect.com/home"
    t.string   "color"
    t.string   "day_to_send_latest_release"
    t.string   "marketplace_name"
    t.string   "time_to_send_latest_release"
    t.boolean  "able_to_see_releases",        :default => false
    t.boolean  "able_to_see_user_guides",     :default => false
    t.boolean  "able_to_see_roadmaps",        :default => false
    t.boolean  "able_to_see_faqs",            :default => false
    t.boolean  "able_to_see_supports",        :default => false
    t.string   "api_key"
    t.boolean  "able_to_see_isv",             :default => false
    t.string   "marketplace_account_status"
    t.string   "marketplace_edition"
  end

  add_index "channel_partners", ["subdomain"], :name => "index_channel_partners_on_subdomain"

  create_table "channel_partners_channel_specific_contents", :force => true do |t|
    t.integer "channel_partner_id"
    t.integer "channel_specific_content_id"
  end

  create_table "channel_partners_channel_specific_states", :force => true do |t|
    t.integer "channel_partner_id"
    t.integer "channel_specific_state_id"
  end

  create_table "channel_partners_features", :id => false, :force => true do |t|
    t.integer "feature_id"
    t.integer "channel_partner_id"
  end

  create_table "channel_partners_hotfixes", :force => true do |t|
    t.integer "hotfix_id"
    t.integer "channel_partner_id"
  end

  create_table "channel_partners_users", :force => true do |t|
    t.integer "account_rep_id"
    t.integer "channel_partner_id"
  end

  create_table "channel_specific_contents", :force => true do |t|
    t.string   "channel_specific_type"
    t.integer  "channel_specific_id"
    t.text     "content"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.boolean  "whitelist"
  end

  create_table "channel_specific_states", :force => true do |t|
    t.string   "channel_specific_state_type"
    t.integer  "channel_specific_state_id"
    t.string   "task"
    t.string   "status"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "channel_partner_id"
  end

  create_table "custom_links", :force => true do |t|
    t.string   "label"
    t.string   "url"
    t.string   "link_type"
    t.integer  "channel_partner_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "descriptions", :force => true do |t|
    t.text     "tag_description"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "faqs", :force => true do |t|
    t.string   "question"
    t.text     "answer"
    t.string   "pub_status"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "slug"
  end

  create_table "features", :force => true do |t|
    t.string   "title"
    t.text     "summary"
    t.integer  "release_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.text     "content"
    t.string   "pub_status"
    t.datetime "merge_date"
  end

  create_table "friendly_id_slugs", :force => true do |t|
    t.string   "slug",                         :null => false
    t.integer  "sluggable_id",                 :null => false
    t.string   "sluggable_type", :limit => 40
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type"], :name => "index_friendly_id_slugs_on_slug_and_sluggable_type", :unique => true
  add_index "friendly_id_slugs", ["sluggable_id"], :name => "index_friendly_id_slugs_on_sluggable_id"
  add_index "friendly_id_slugs", ["sluggable_type"], :name => "index_friendly_id_slugs_on_sluggable_type"

  create_table "hotfixes", :force => true do |t|
    t.string   "number"
    t.integer  "release_id"
    t.text     "content"
    t.string   "pub_status"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "mailing_lists", :force => true do |t|
    t.string   "title"
    t.boolean  "joinable"
    t.boolean  "internal_only"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "subject"
    t.string   "description"
    t.boolean  "event_based"
  end

  create_table "open_id_urls", :force => true do |t|
    t.string  "open_id_url"
    t.integer "channel_partner_id"
  end

  create_table "openid_associations", :force => true do |t|
    t.datetime "issued_at"
    t.integer  "lifetime"
    t.string   "assoc_type"
    t.text     "handle"
    t.binary   "secret"
    t.string   "target"
    t.text     "server_url"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "openid_nonces", :force => true do |t|
    t.integer  "timestamp"
    t.string   "salt"
    t.string   "target"
    t.text     "server_url"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "pages", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.string   "slug"
    t.string   "permalink"
    t.string   "ancestry"
    t.integer  "sortable_order"
    t.string   "pub_status"
    t.datetime "page_pub_date"
    t.integer  "ancestry_depth",             :default => 0
    t.text     "subsection_headings"
    t.boolean  "redirect_to_first_child",    :default => false
    t.string   "type"
    t.boolean  "is_framemaker",              :default => false
    t.string   "framemaker_page_id"
    t.string   "framemaker_export_location"
    t.string   "framemaker_book"
    t.string   "framemaker_chapter"
    t.string   "logo"
    t.string   "summary"
  end

  add_index "pages", ["ancestry"], :name => "index_pages_on_ancestry"
  add_index "pages", ["permalink"], :name => "index_pages_on_permalink"
  add_index "pages", ["slug"], :name => "index_pages_on_slug"

  create_table "passages", :force => true do |t|
    t.text     "content"
    t.integer  "sortable_order"
    t.string   "passages_type"
    t.integer  "passages_id"
    t.string   "type_name"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "remote_content"
  end

  create_table "permissions", :force => true do |t|
    t.string  "action"
    t.string  "subject_class"
    t.integer "subject_id"
    t.integer "role_id"
  end

  create_table "pg_search_documents", :force => true do |t|
    t.text     "content"
    t.integer  "searchable_id"
    t.string   "searchable_type"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "read_marks", :force => true do |t|
    t.integer  "readable_id"
    t.integer  "user_id",                     :null => false
    t.string   "readable_type", :limit => 20, :null => false
    t.datetime "timestamp"
  end

  add_index "read_marks", ["user_id", "readable_type", "readable_id"], :name => "index_read_marks_on_user_id_and_readable_type_and_readable_id"

  create_table "releases", :force => true do |t|
    t.string   "title"
    t.date     "release_date"
    t.text     "summary"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
    t.string   "slug"
    t.string   "pub_status"
    t.text     "marketplace_improvements"
    t.text     "manager_improvements"
    t.text     "devcenter_improvements"
    t.text     "api_improvements"
    t.text     "subsection_headings"
    t.text     "corporate_portal"
    t.text     "general_notes"
  end

  add_index "releases", ["title"], :name => "index_releases_on_title"

  create_table "rich_rich_files", :force => true do |t|
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.string   "rich_file_file_name"
    t.string   "rich_file_content_type"
    t.integer  "rich_file_file_size"
    t.datetime "rich_file_updated_at"
    t.string   "owner_type"
    t.integer  "owner_id"
    t.text     "uri_cache"
    t.string   "simplified_type",        :default => "file"
  end

  create_table "roadmaps", :force => true do |t|
    t.string   "title"
    t.string   "product"
    t.string   "pub_status"
    t.integer  "release_id"
    t.text     "content"
    t.string   "slug"
    t.string   "permalink"
    t.boolean  "redirect_to_first_child"
    t.text     "subsection_headings"
    t.integer  "sortable_order"
    t.string   "ancestry"
    t.integer  "ancestry_depth",          :default => 0
    t.boolean  "is_a_quarter",            :default => false
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "roles", ["name", "resource_type", "resource_id"], :name => "index_roles_on_name_and_resource_type_and_resource_id"
  add_index "roles", ["name"], :name => "index_roles_on_name"

  create_table "tag_descriptions", :force => true do |t|
    t.string   "description"
    t.integer  "tag_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       :limit => 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], :name => "taggings_idx", :unique => true

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  add_index "tags", ["name"], :name => "index_tags_on_name", :unique => true

  create_table "updates", :force => true do |t|
    t.string   "title"
    t.text     "content"
    t.date     "release_date"
    t.string   "pub_status"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",   :null => false
    t.string   "encrypted_password",     :default => "",   :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.string   "name"
    t.integer  "channel_partner_id"
    t.string   "phone"
    t.string   "avatar"
    t.integer  "impersonation_id"
    t.boolean  "show_update"
    t.boolean  "quickstart",             :default => true
  end

  add_index "users", ["email", "channel_partner_id"], :name => "index_users_on_email_and_channel_partner_id", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "users_mailing_lists", :force => true do |t|
    t.integer "user_id"
    t.integer "mailing_list_id"
  end

  create_table "users_roles", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], :name => "index_users_roles_on_user_id_and_role_id"

  create_table "versions", :force => true do |t|
    t.string   "item_type",      :null => false
    t.integer  "item_id",        :null => false
    t.string   "event",          :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

end
