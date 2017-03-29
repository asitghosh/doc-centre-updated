ActiveAdmin.register Support do
    config.paginate = false

    filter :title
    filter :updated_at
    filter :pub_status
    # member_action :update, :method => :put do
    #   support = Support.find(params[:id])
    #   support_attrs = params[:support]
    #
    #   if params[:publish]
    #     support.publish!
    #   elsif params[:draft]
    #     support.redraft! if support.published?
    #   end
    #
    #   if support.update_attributes(support_attrs)
    #     flash[:notice] = "Support guide successfully updated"
    #   else
    #     flash[:error] = "There was a problem saving the support guide"
    #   end
    #
    #   redirect_to({ :action => :index })
    # end

    menu :label => "Help & Support", :parent => "Content", :priority => 1
    # config.sort_order = "support_date_desc"
    #include AdminRedirect
    include AutoSaveable::ActiveAdmin

    action_item :only => [:show, :edit] do
      link_to "View this support", support.permalink
    end

    after_save do |support|
      event = params[:support][:active_admin_requested_event_support]
      # release publishing
      unless event.blank?
        # whitelist to ensure we don't run an arbitrary method
        safe_event = (support.aasm_events_for_current_state & [event.to_sym]).first
        raise "Forbidden event #{event} requested on instance #{support.id}" unless safe_event
        # launch the event with bang
        support.send("#{safe_event}!")
      end
    end

    action_item :only => [:show, :edit] do
      link_to "View this support guide", support.permalink
    end

    index :title => "supports" do
      render "index"
    end

    show :title => "supports" do
      attributes_table do
        row :title
      end

      panel "Passages" do
        table_for support.passages do
          column "Tags" do |passage|
            passage.tags.pluck(:name).join(", ")
          end
          column "Content" do |passage|
            raw passage.content
          end
        end
      end
    end

    form do |f|
      f.semantic_errors *f.object.errors.keys
      f.actions
      f.inputs "Support Data", :id => "support_data", :'data-class' => "Support", :'data-id' => f.object.id do
        f.input :title, :label => "Support Title"
        f.input :parent_id, :as => :select, :collection => options_for_select([["Root", ""]].concat(Support.all.map { |s| ["-" * s.depth + " " + s.title, s.id]}), support.parent_id.nil? ? params[:parent_id] : support.parent_id ), :input_html => { :class => "chosen-input" , :style => "width: 700px"}
        f.input :redirect_to_first_child, :as => :boolean
        f.input :pub_status, :input_html => { :disabled => true }, :label => 'Current status'
        f.input :active_admin_requested_event_support, :label => 'Change status', :as => :select, :collection => f.object.aasm_events_for_current_state
      end

      f.template.render 'admin/shared/passage', f: f
      #f.template.render 'admin/shared/channel_specific', f: f

      f.actions
    end

end
