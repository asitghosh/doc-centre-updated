ActiveAdmin.register ChannelPartner do
    menu :label => "All Partners", parent: "Channel Partners"

    filter :name
    filter :subdomain


    after_save do |channel_partner|
      users         = params[:channel_partner][:users_for_mailing_list].reject(&:empty?)
      new_users     = users.empty? ? [] : User.where("id IN(#{users.join(',')})")
      mailinglist   = MailingList.find_by_title("Channel Partner Mailing List")
      current_users = mailinglist.users.where(:channel_partner_id => channel_partner.id)
      users_to_add  = new_users - current_users
      users_to_drop = current_users - new_users

      users_to_add.each do |user|
        mailinglist.users << user
      end

      users_to_drop.each do |user|
        mailinglist.users.delete(user)
      end

    end

    index do
      column :name, :sortable => :name do |channel_partner|
        link_to channel_partner.name, details_admin_channel_partner_path(channel_partner)
      end
      column "Access URL", :sortable => :subdomain do |channel_partner|
        link_to "https://#{channel_partner.subdomain}.docs.appdirect.com", "https://#{channel_partner.subdomain}.docs.appdirect.com"
      end
      column :account_reps, :sortable => false do |channel_partner|
        channel_partner.account_reps.each do |rep|
          text_node link_to rep.name, admin_user_path(rep)
          text_node "&nbsp".html_safe
        end
      end

      column "Total Logins", :sortable => false do |channel_partner|
        channel_partner.users.sum('sign_in_count')
      end
      default_actions
    end

    form do |f|
      mailinglist = MailingList.find_by_title("Channel Partner Mailing List")
      current_users = mailinglist.users.where(:channel_partner_id => channel_partner.id)
      f.actions
      f.inputs "Channel Partner Info" do
        f.input :name
        f.input :open_id_address,
                :as => :hidden,
                :hint => "This is usually found by adding /openid/id to the marketplace url e.g. https://marketplace.url/openid/id"
        f.input :subdomain
        f.input :marketplace_name
        f.input :marketplace_url
        f.input :marketplace_edition, 
                :as => :select, 
                :collection => options_for_select([["Billing", "BILLING"], ["Listing", "LISTING"], ["Store", "STORE"], ["Ecosystem", "ECOSYSTEM"], ["Network", "NETWORK"]], f.object.marketplace_edition)
        f.input :marketplace_account_status,
                :as => :select,
                :collection => options_for_select([["Paid", "PAID"], ["Free", "FREE"], ["Free Trial", "FREE_TRIAL"], ["Free Trial Expired", "FREE_TRIAL_EXPIRED"]], f.object.marketplace_account_status)
        f.input :logo, :as => :rich_picker
        f.input :color,
                :hint => "6 digit hex value with no leading '#'"
        f.input :api_key, 
                :input_html => { :disabled => true },
                :hint => "Important! This should never be provided to the channel partner."
        f.input :day_to_send_latest_release,
                :hint => "Setting this will email the users below the latest release notes on the day indicated.",
                :as => :select,
                :collection => options_for_select(["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"], { selected: f.object.day_to_send_latest_release } ),
                :include_blank => "Don't Send"
        f.input :time_to_send_latest_release,
                :hint => "Hour to send latest release note",
                :collection => options_for_select((0..24).to_a, { selected: f.object.time_to_send_latest_release } ),
                :include_blank => "Don't Send"
        f.input :users_for_mailing_list,
                :hint => "These users will get the latest release note with PDF on the day & time chosen above",
                :as => :select,
                :collection => options_from_collection_for_select(f.object.users, 'id', 'name', { selected: current_users.collect { |u| u.id.to_s } }),
                :input_html => { :multiple => true, :class => "chosen-input", :style => "width: 700px;" }

        f.input :account_reps, :as => :select, :collection => User.with_role(:account_rep),  :input_html => { :class => "chosen-input",  :style => "width: 200px;"}
      end
      f.inputs "Open ID URLs" do
        f.has_many :open_id_urls do |lform|
          lform.input :open_id_url, :hint => "This is usually found by adding /openid/id to the marketplace url e.g. https://marketplace.url/openid/id"
        end
      end
      f.inputs "Channel Partner Permissions" do
        f.input :able_to_see_releases, :label => "Releases"
        f.input :able_to_see_roadmaps, :label => "Roadmap"
        f.input :able_to_see_supports, :label => "Support Guide"
        f.input :able_to_see_faqs, :label => "FAQs"
        f.input :able_to_see_user_guides, :label => "User Guide"
        f.input :able_to_see_isv, :label => "ISV Application Info"
      end
      f.inputs "Links for Channel Partner" do
        f.has_many :custom_links do |lform|
          lform.input :label
          lform.input :url
          lform.input :link_type, :as => :select, :collection => options_for_select([["Support", "support"], ["General", "links"]], lform.object.link_type)
          lform.input :_destroy, :as => :boolean
        end
      end
      f.actions
    end

    member_action :details do
      @channel_partner = ChannelPartner.find(params[:id])
      @page_title = "#{@channel_partner.name}: Details"

      # This will render app/views/admin/channel_partners/details.html.erb
    end
end
