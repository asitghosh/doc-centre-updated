ActiveAdmin.register Roadmap do
  include AutoSaveable::ActiveAdmin
  menu :label => "Roadmap", :parent => "Content", :priority => 3

  filter :title
  filter :pub_status
  filter :updated_at
# event :start_work do
#   transitions :from => :planned, :to => :in_progress
# end
#
# event :ongoing do
#   transitions :from => [:planned, :in_progress], :to => :ongoing
# end
#
# event :finish do
#   transitions :from => [:planned, :in_progress, :ongoing], :to => :complete
# end
  after_save do |roadmap|
    event = params[:roadmap][:active_admin_requested_event]
    # release publishing
    unless event.blank?
      # whitelist to ensure we don't run an arbitrary method
      safe_event = (roadmap.aasm_events_for_current_state & [event.to_sym]).first
      raise "Forbidden event #{event} requested on instance #{roadmap.id}" unless safe_event
      # launch the event with bang
      roadmap.send("#{safe_event}!")
    end
  end

  config.paginate = false
  config.sort_order = "sortable_order_asc"

  action_item :only => [:show, :edit] do
    link_to "View this page", resource.permalink
  end

  index :title => "Guide" do
    render "index"
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys

    f.inputs "Roadmap", :id => "resource_data", :'data-class' => "Roadmap", :'data-id' => f.object.id do
      f.input :title
      f.input :pub_status, :input_html => { :disabled => true }, :label => 'Current status'
      f.input :active_admin_requested_event,
              :label => 'Change status',
              :hint => "draft => planned (publish) => in progress (start work) => ongoing (ongoing) => complete (finish)",
              :as => :select,
              :collection => f.object.aasm_events_for_current_state
      f.input :parent_id, :as => :select,
              :collection => options_for_select([["Root", ""]].concat(Roadmap.all.map { |p| ["-" * p.depth + " " + p.title, p.id]}), f.object.parent_id.nil? ? params[:parent_id] : f.object.parent_id ), :input_html => { :class => "chosen-input",  :style => "width: 700px;"}
      f.input :redirect_to_first_child, :as => :boolean
      f.input :is_a_quarter, :as => :boolean
      f.input :product,
              :as => :select,
              :collection => ["Marketplace Manager", "Reseller", "Billing", "Mobile MyApps", "Developer Services", "Cloud Infrastructure & Services", "Productivity & Domains", "Reporting & Monitoring", "App Manager", "Identity & Access Management", "Marketplace"]
      f.input :content, :as => :rich, :config => { :width => '76%', :height => '400px' }

      f.actions
    end
  end


end
