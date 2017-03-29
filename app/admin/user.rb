ActiveAdmin.register User do
  config.clear_action_items!
  actions :all, :except => [:new]

  filter :roles
  filter :channel_partner
  filter :email
  filter :name
  filter :phone

  menu :label => "All Users", :parent => "Members"
  index do
    column :email do |user|
      link_to user.email , activity_admin_user_path(user)
    end
    column :channel_partner_id do |user|
      raw user.channel_partner.name
    end
    column :current_sign_in_at
    column :last_sign_in_at do |user|
      "#{time_ago_in_words(user.last_sign_in_at)} ago"
    end
    column :sign_in_count
    default_actions
  end

  show do |user|
    attributes_table do
      row :name
      row :avatar do |user|
        avatar_for user
      end
      row :phone
      row :email do |user|
        mail_to user.email
      end
    end
  end

  form do |f|
    f.inputs "User Details" do
      f.input :email
      # f.input :password
      # f.input :password_confirmation
      f.input :avatar, :as => :rich_picker
      f.input :phone
      f.input :roles, :as => :select, :collection => Role.all, :input_html => { :class => "chosen-input",  :style => "width: 700px;"}
      f.input :channel_partner_id, :as => :select, :collection => ChannelPartner.all
      f.input :mailing_lists, :as => :select, :collection => MailingList.all, :input_html => { :class => "chosen-input", :style => "width: 700px;" }
    end
    f.buttons
  end

  create_or_edit = Proc.new {
    @user            = User.find_or_create_by_id(params[:id])
    @user.add_role :superadmin
    @user.attributes = params[:user].delete_if do |k, v|
      (k == "superadmin") ||
      (["password", "password_confirmation"].include?(k) && v.empty? && !@user.new_record?)
    end
    if @user.save
      redirect_to :action => :show, :id => @user.id
    else
      render active_admin_template((@user.new_record? ? 'new' : 'edit') + '.html.erb')
    end
  }
  member_action :create, :method => :post, &create_or_edit
  member_action :update, :method => :put, &create_or_edit

  member_action :activity do
    @user = User.find(params[:id])
    @page_title = "#{@user.name}: Activity"
    @activity = {
      :releases => Release.unread_by(@user),
      :pages => Page.unread_by(@user),
      :features => Feature.unread_by(@user)
    }

    # This will render app/views/admin/users/activity.html.erb
  end

  action_item :only => [:index] do
    link_to "Edit Your Profile", edit_admin_user_path(current_user)
  end

end
