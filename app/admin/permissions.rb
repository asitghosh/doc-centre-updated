ActiveAdmin.register Permission do
  menu false
  #menu :label => "Permissions",  :parent => "Member Mgmt"
  form do |f|
    f.inputs "Permission Details" do
      f.input :role
      f.input :action,        collection: DocCenter::Application.config.cancan_actions
      f.input :subject_class, label: "Type", collection: DocCenter::Application.config.role_models
    end
    f.actions
  end
end
