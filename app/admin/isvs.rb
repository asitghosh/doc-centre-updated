ActiveAdmin.register Isv do
  config.paginate = false
  # batch_action :flag do |selection|
  #   Post.find(selection).each { |p| p.flag! }
  #   redirect_to collection_path, :notice => "Posts flagged!"
  # end

  filter :title
  filter :updated_at

  after_save do |isv|
    event = params[:isv][:active_admin_requested_event]
    # release publishing
    unless event.blank?
      # whitelist to ensure we don't run an arbitrary method
      safe_event = (isv.aasm_events_for_current_state & [event.to_sym]).first
      raise "Forbidden event #{event} requested on instance #{isv.id}" unless safe_event
      # launch the event with bang
      isv.send("#{safe_event}!")
    end
  end

  menu :label => "ISV Info", :parent => "Content", :priority => 4

  config.sort_order = "sortable_order_asc"

  include AutoSaveable::ActiveAdmin

  action_item :only => [:show, :edit] do
    link_to "View this page", isv.permalink
  end

  index :title => "ISV Information" do
    @isvs = Isv.unscoped.all
    render "index"
  end

  #

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.actions
    # wanted to add the data attributes to the form itself, but the page var isn't available until inside the block
    f.inputs "Page", :id => "resource_data", :'data-class' => "Page", :'data-id' => f.object.id do
      f.input :title

      f.input :parent_id,
              :as => :select,
              :collection => options_for_select([["Root", ""]].concat(Isv.all.map { |p| ["-" * p.depth + " " + p.title, p.id]}), f.object.parent_id.nil? ? params[:parent_id] : f.object.parent_id ),
              :input_html => { :class => "chosen-input",  :style => "width: 700px;"}
      f.input :pub_status, :input_html => { :disabled => true }, :label => 'Current status'
      f.input :active_admin_requested_event, :label => 'Change status', :as => :select, :collection => f.object.aasm_events_for_current_state
      f.input :page_pub_date,
              :as => :datepicker

      unless f.object.new_record? or f.object.body.blank?
        f.input :body,
                :as => :rich,
                :config => { :width => '76%', :height => '400px' }
      end

      f.input :redirect_to_first_child, :as => :boolean


    end

    f.template.render 'admin/shared/passage', f: f
    f.template.render 'admin/shared/channel_specific', f: f

    f.actions
  end

end
