ActiveAdmin.register Role do
  menu :label => "Roles", :parent => "Members", if: Proc.new { current_user.has_role? :superadmin }
  form do |f|
    f.inputs "Role" do
      f.input :name
    end

    f.inputs "Permissions" do
      f.has_many :permissions do |pform|
        unless pform.object.new_record?
          pform.input :_destroy, :as => :boolean, :label => "Delete?"
        end
        pform.input :action,        collection: DocCenter::Application.config.cancan_actions
        pform.input :subject_class, label: "Type", collection: DocCenter::Application.config.role_models
      end
    end
    f.buttons
  end

end
