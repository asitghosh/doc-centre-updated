ActiveAdmin.register Release do
  menu :label => "Releases", :parent => "Content", :priority => 1
  config.sort_order = "release_date_desc"
  #include AdminRedirect
  include AutoSaveable::ActiveAdmin

  filter :title
  filter :pub_status
  filter :marketplace_improvements
  filter :manager_improvements
  filter :devcenter_improvements
  filter :api_improvements
  filter :corporate_portal
  filter :updated_at


  action_item :only => [:show, :edit] do
    link_to "View this release", release_path(resource)
  end

  after_save do |release|
    event = params[:release][:active_admin_requested_event]
    hotfixes = params[:release][:hotfixes_attributes]
    # release publishing
    unless event.blank?
      # whitelist to ensure we don't run an arbitrary method
      safe_event = (release.aasm_events_for_current_state & [event.to_sym]).first
      raise "Forbidden event #{event} requested on instance #{release.id}" unless safe_event
      # launch the event with bang
      release.send("#{safe_event}!")
    end
    # hotfix publishing
    unless hotfixes.blank?
      hotfixes.each do |hotfix, attributes|
        event = attributes[:active_admin_requested_event]
        unless event.blank?
          hotfix = release.hotfixes.where(:number => attributes[:number]).first
          safe_event = (hotfix.aasm_events_for_current_state & [event.to_sym]).first
          raise "Forbidden event #{event} requested on instance #{release.id}" unless safe_event

          hotfix.send("#{safe_event}!")
        end
      end
    end

  end

  index do |release|
    selectable_column
    column "Title", :sortable => :title do |release|
      link_to "Release #{release.title}", edit_admin_release_path(release)
    end
    column :pub_status
    column :release_date
    default_actions
  end

  show do |release|
    attributes_table do
      row :title
      row :pub_status
      row :release_date
      row :summary do
        raw release.summary
      end
      row :marketplace_improvements do
        raw release.marketplace_improvements
      end
      row :manager_improvements do
        raw release.manager_improvements
      end
      row :devcenter_improvements do
        raw release.devcenter_improvements
      end
      row :api_improvements do
        raw release.api_improvements
      end
      row :corporate_portal do
        raw release.corporate_portal
      end
      row :features do
        ul do
          release.features.each do |feature|
            li link_to "#{feature.title}", admin_feature_path(feature)
          end
        end
      end
      row :channel_specific_contents do
        ul do
          release.channel_specific_contents.each do |csc|
            li do
              # h4 link_to csc.channel_partner.name, admin_channel_partner_path(csc.channel_partner)
              div raw csc.content
            end
          end
        end
      end
      row :hotfixes do
        ul do
          release.hotfixes.each do |hotfix|
            li do
              div raw hotfix.number
              div raw hotfix.content
              unless hotfix.channel_specific_contents.blank?
                ul do
                  hotfix.channel_specific_contents.each do |csc|
                    li do
                      h4 do
                        csc.channel_partners.each do |cp|
                          span cp.name
                        end
                      end
                      div raw csc.content
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
    active_admin_comments
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.actions
    f.inputs "Release Data", :id => "resource_data", :'data-class' => "Release", :'data-id' => f.object.id do
      f.input :title, :label => "Release Number"
      f.input :pub_status, :input_html => { :disabled => true }, :label => 'Current status'
      f.input :active_admin_requested_event, :label => 'Change status', :as => :select, :collection => f.object.aasm_events_for_current_state
      f.input :release_date, :as => :datepicker
      f.input :summary
      f.input :general_notes, :as => :rich
    end

    f.template.render 'admin/shared/passage', f: f, headline: "Marketplace Improvements", old_field: "Marketplace Improvements", type_name: "marketplace_improvements"
    f.template.render 'admin/shared/passage', f: f, headline: "Manager Improvements", old_field: "Manager Improvements", type_name: "manager_improvements"
    f.template.render 'admin/shared/passage', f: f, headline: "DevCenter Improvements", old_field: "DevCenter Improvements", type_name: "devcenter_improvements"
    f.template.render 'admin/shared/passage', f: f, headline: "API Improvements", old_field: "API Improvements", type_name: "api_improvements"
    f.template.render 'admin/shared/passage', f: f, headline: "Corporate Portal", old_field: "Corporate Portal", type_name: "corporate_portal"

    f.template.render 'admin/shared/channel_specific', f: f

    f.inputs "Hotfixes" do
      f.has_many :hotfixes do |hform|
        hform.input :channel_partners, :input_html => { :class => "chosen-input", :style => "width: 700px;" }
        hform.input :number
        hform.input :pub_status, :input_html => { :disabled => true }, :label => 'Current status'
        hform.input :active_admin_requested_event, :label => 'Change status', :as => :select, :collection => hform.object.aasm_events_for_current_state
        hform.input :content, :as => :rich, :config => { :width => '76%', :height => '400px' }
        hform.has_many :channel_specific_contents do |sform|
          sform.input :whitelist, :as => :select, :label => "Partner List Type", :collection => options_for_select([["Whitelist", "true"], ["Blacklist", "false"]], sform.object.whitelist), :include_blank => false
          sform.input :channel_partners, :input_html => { :class => "chosen-input",  :style => "width: 700px;"}
          sform.input :content, :as => :rich, :config => { :width => '76%', :height => '400px' }
          sform.input :_destroy, :as => :boolean
        end
        hform.input :_destroy, :as => :boolean
      end
    end
    f.actions
  end
end
