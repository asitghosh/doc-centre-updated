require 'find'

ActiveAdmin.register Api do
    config.paginate = false

    filter :title
    filter :updated_at
    filter :pub_status

    menu :label => "Public Pages", :parent => "Content", :priority => 1
    # config.sort_order = "support_date_desc"
    #include AdminRedirect
    include AutoSaveable::ActiveAdmin

    action_item :only => [:show, :edit] do
      link_to "View this Page", api.permalink
    end

    after_save do |api|
      event = params[:api][:active_admin_requested_event_api]
      # release publishing
      unless event.blank?
        # whitelist to ensure we don't run an arbitrary method
        safe_event = (api.aasm_events_for_current_state & [event.to_sym]).first
        raise "Forbidden event #{event} requested on instance #{api.id}" unless safe_event
        # launch the event with bang
        api.send("#{safe_event}!")
      end
    end

    sidebar :annotations , only: :edit do
      ul class: "annotation-list" do
        api.annotations.keep_if{ |a| a.aasm_state == "submitted" }.each do |annotation|
          li class: "annotation-list-item" do
            h5 "Comment Type: #{annotation.classification}"
            h5 "Submitted by: #{annotation.user}"
            h5 "On: #{annotation.updated_at.to_s(:short) }"
            h5 "Selected Text: #{annotation.quote}"
            h5 "Comment: #{annotation.text}"
            h5 link_to "Resolve", api_v1_annotation_resolve_path(annotation), class: "btn btn-primary js-remove", remote: true
          end
        end
      end
    end

    index :title => "apis" do
      render "index"
    end

    show :title => "apis" do
      attributes_table do
        row :title
      end

      panel "Passages" do
        table_for api.passages do
          column "Tags" do |passage|
            passage.tags.pluck(:name).join(", ")
          end
          column "Content" do |passage|
            raw passage.content
          end
        end
      end

      panel "Annotations" do
        table_for api.annotations do
          column "Submitted by" do |annotation|
            annotation.user
          end
          column "Classification" do |annotation|
            annotation.classification
          end
          column "On" do |annotation|
            annotation.updated_at.to_s(:short) 
          end
          column "Selected Text" do |annotation|
            annotation.quote
          end
          column "Comment" do |annotation|
            annotation.text
          end
          column "Status" do |annotation|
            annotation.aasm_state
          end
        end
      end
    end

    form do |f|
      f.semantic_errors *f.object.errors.keys
      f.actions
      f.inputs "Page Data", :id => "api_data", :'data-class' => "Api", :'data-id' => f.object.id do
        f.input :title, :label => "Support Title"
        f.input :parent_id, :as => :select, :collection => options_for_select([["Root", ""]].concat(Api.all.map { |s| ["-" * s.depth + " " + s.title, s.id]}), api.parent_id.nil? ? params[:parent_id] : api.parent_id ), :input_html => { :class => "chosen-input" , :style => "width: 700px"}
        f.input :redirect_to_first_child, :as => :boolean
        f.input :pub_status, :input_html => { :disabled => true }, :label => 'Current status'
        f.input :active_admin_requested_event_api, :label => 'Change status', :as => :select, :collection => f.object.aasm_events_for_current_state
        f.input :logo, :as => :rich_picker
        f.input :summary
        f.input :is_framemaker, :label => "Is this a FrameMaker page?"
        f.input :framemaker_book, :label => "Framemaker Book", 
                                  :hint => "Only used for filtering the 'Framemaker Page' field.",
                                  :as => :select,  
                                  :collection => options_for_select(Dir.glob(Rails.root.join("public", "framemaker", "*/").to_s).map! { |p| p = [p.split("public/framemaker/")[1].gsub("/", ""), "public/#{p.split("public/")[1]}"]}, f.object.framemaker_book), :input_html => { :class => "chosen-input" , :style => "width: 700px"}
        f.input :framemaker_chapter, :label => "Framemaker Chapter",
                                     :hint => "Only used for filtering the 'Framemaker Page' field.",
                                     :as => :select,  
                                     :collection => options_for_select(Dir.glob(Rails.root.join("public", "framemaker", "*/*/").to_s).map! { |p| p = [p.split("public/framemaker/")[1].split("/")[1].gsub("/", ""), "public/#{p.split("public/")[1]}"]}, f.object.framemaker_chapter), :input_html => { :class => "chosen-input" , :style => "width: 700px"}
        f.input :framemaker_export_location, :label => "Framemaker Page", 
                                             :as => :select,  
                                             :collection => options_for_select(Dir.glob(Rails.root.join("public", "framemaker", "**/*.html").to_s ).map! { |p| p = [p.split("framemaker/")[1], "public/#{p.split("public/")[1]}"] }, (f.object.framemaker_export_location.blank? || !File.exists?(f.object.framemaker_export_location) ) ? "" :  "public/" + Dir.glob("#{Rails.root}/public/framemaker/**/*---#{f.object.framemaker_page_id}.html").first.split("public/")[1] ), 
                                             :input_html => { :class => "chosen-input" , :style => "width: 700px"}
        f.input :framemaker_page_id, :label => "Framemaker PageID"
      end

      f.template.render 'admin/shared/passage', f: f
      f.template.render 'admin/shared/channel_specific', f: f

      f.actions
    end

end
