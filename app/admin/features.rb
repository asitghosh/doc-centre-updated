ActiveAdmin.register Feature do
  menu false
  #menu :label => "Features", :parent => "Content", :priority => 2  

  include AutoSaveable::ActiveAdmin

  member_action :update, :method => :put do
    feature = Feature.find(params[:id])
    feature_attrs = params[:feature]

    if params[:publish]
      feature.publish!
    elsif params[:draft]
      feature.redraft! if feature.published?
    end

    if feature.update_attributes(feature_attrs)
      flash[:notice] = "Feature successfully updated"
    else
      flash[:error] = "There was a problem saving the Feature"
    end

    redirect_to({ :action => :index })
  end

  action_item :only => [:show, :edit] do
    link_to "View this feature", feature_path(feature)
  end

  index do |feature|
    selectable_column
    column "Title", :sortable => :title do |feature|
      link_to feature.title, edit_admin_feature_path(feature)
    end
    column :pub_status
    column "summary" do |feature|
      raw feature.summary
    end
    default_actions
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.actions do
      f.action :submit, :label => f.object.published? ? "Revert to Draft" : "Save Draft", :button_html => { :class => "secondary", :name => "draft" }
      f.action :submit, :label => f.object.published? ? 'Update Published Page' : 'Publish', :button_html => { :class => "primary", :name => f.object.published? ? 'update' : 'publish' }
    end
    f.inputs "Feature", :id => "resource_data", :'data-class' => "Feature", :'data-id' => feature.id do
      f.input :release
      f.input :title
      f.input :channel_partners, :input_html => { :class => "chosen-input", :style => "width: 700px;"}, :collection => options_for_select(([["All Partners", ""]] + ChannelPartner.all.collect { |c| [c.name, c.id] }), f.object.channel_partner_ids.empty? ? "" : f.object.channel_partner_ids)
      f.input :pub_status, :as => :select, :collection => options_for_select([["Draft", "draft"], ["Published", "published"]], feature.pub_status), :include_blank => false
      f.input :summary, :as => :rich
      f.input :content, :as => :rich
    end
    f.actions do
      f.action :submit, :label => f.object.published? ? "Revert to Draft" : "Save Draft", :button_html => { :class => "secondary", :name => "draft" }
      f.action :submit, :label => f.object.published? ? 'Update Published Page' : 'Publish', :button_html => { :class => "primary", :name => f.object.published? ? 'update' : 'publish' }
    end
  end
end
